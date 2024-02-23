require 'dicom'
require 'rmagick'
require 'net/http'
require 'net/https'
require 'json'
require 'fileutils'
require 'thread'
require 'parallel'
require 'date'
# require 'datetime'

require_relative 'lib/lib'

include Magick
include DICOM

# ae_title = 'SYNAPSEDICOM'
# ae_title = 'DICOM'
# ae_ip = '10.5.31.112'
# ae_ip = '10.5.31.68'
# ae_ip = '10.39.43.20'
# ae_port = '104'
#
# host = 'https://gi.emr.med'
# date = Time.now.strftime("%d/%m/%Y")
# uri = URI("#{host}/endo/Api/get_emr_image?date=#{date}")
#
#


ae_title = 'SYNAPSEDICOM'

ae_title = 'ORTHANC'
ae_ip = '10.5.31.112'
ae_ip = '10.5.31.68'
ae_ip = 'localhost'
ae_port = '4242'

# ae_ip = '10.149.1.42'
# ae_port = '104'
# ae_title = 'KCMH'

# ae_ip = '192.168.0.116'
# ae_port = '104'
# ae_title = 'KCMH'



host = 'https://gi.emr.med'
host = 'https://colo.emr-life.com'
host = 'https://colo.emrlife.com'


date = Time.now.strftime("%d/%m/%Y")
date = DateTime.parse("2023-12-14")

uri = URI("#{host}/colo/Api/get_emr_image?date=#{date}")

puts uri


while true


http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)

content = response.body

data = JSON.parse(content)


 puts data.inspect

storage = "media/dicom"
run_stamp = date.strftime("%Y/%m/%d")




list = data['data']

index = 0
#list = list[0..0]

for i in list

work_q = Queue.new




id = i['module_id']
id = i['module_id']['$oid'] if i['module_id'].is_a?(Hash)


# puts i.inspect
path = File.join(storage,run_stamp,id)

# stage 1 test folder created

FileUtils.mkdir_p path unless File.exists?(path)


stamp = DateTime.parse(i['created_at'])       
     

index_id = index + 1

if i['index']
  index_id = i['index']+1
end

index +=1


acc =  "#{stamp.strftime("%Y%m%d")}GI#{format('%04d',index_id)}"

acc =   i['acc'] if i['acc']      




now = Time.now

# main_options 
        study_id = "1.2.392.200036.9125.192045027129104.#{stamp.strftime("%Y%m%d")}#{format('%04d',index_id)}"
  
  
        options = {} 
  
        options[:hn] = i['hn'].split('/').join('-')
        options[:patient_name] = i['name']
        options[:patient_age] = i['age']
        options[:patient_gender] = i['gender']
        
        options[:modality] = 'SC'
        options[:study_at] = stamp
        options[:record_at] = Date.parse(i['created_at'])
        options[:idx] = 0
        options[:ae] = 'EMRENDOSCOPE'
        options[:station_name] = 'GI-Report'
        options[:model_name] = 'SCOPE-LIFE'
        options[:manufacturer] = 'E.S.M.Solution Co.,Ltd.'
        options[:device_sn] = '00000'
        options[:sw_version] = '2.0.1'
        options[:acc] = acc
        options[:study_id] = study_id
        options[:note] = i['title']
       
        options[:study_name] = i['ae'].upcase
        
        main_options = options
         
        report_id = i['id']
        report_id = report_id['$oid'] if report_id['$oid']
        i['id'] = report_id
if i['report'] 
  
  rpath = File.join(path, "r_#{i['id']}.pdf")
   
  unless File.exists?(rpath)
  
  puts 'Generate Report '+i['report']
 
  report_url = "#{host}/#{i['report']}"
  cmd = "wkhtmltopdf '#{report_url}' #{rpath}"
  out = `#{cmd}`
  
  report_options = main_options.clone 
  report_options[:idx] = 9000
  report_options[:series_uid] = study_id+".9000"
  report_options[:procedure] = 'Report'
          
  convert_dicom rpath, report_options
  
  dpath = File.join(path, "r_#{i['id']}.dcm")

  logpath = File.join(path, "r_#{i['id']}.log") 
  
  
	cmx = "storescu -v -xe -to 5  -aec #{ae_title} #{ae_ip} #{ae_port} #{dpath}"
  log = `#{cmx}` #dcmsend -aet EMRENDOSCOPE -aec #{ae_title} -v #{ae_ip} #{ae_port} #{dpath}`
  
  puts cmx
  
	out = File.open(logpath,'w')
  out.puts cmx
	out.close
  
  
  end
  
end
         
         
         
         
         
         
 Parallel.map(i['imgs'], in_processes: 10) do |j|
            
   
    
         # stage 2 test all image download


           fpath = File.join(path, "#{j['id']}.jpg")
           furi = "#{host}#{j['path']}"

           puts "image :  - #{j['path']}"
           unless File.exists?(fpath)
             `curl --insecure #{furi} > #{fpath}`
           end
           
           puts fpath
           
           dpath = File.join(path, "#{j['id']}.dcm")
           logpath = File.join(path, "#{j['id']}.log")

         unless File.exists?(dpath)
          

          
          options = main_options.clone
          
        
                    
                    
          options[:hn] = i['hn'].split('/').join('-')
          options[:patient_name] = i['name']
          options[:patient_age] = i['age']
          options[:patient_gender] = i['gender']
          
          options[:modality] = 'ES'
          options[:study_at] = stamp
          options[:record_at] = Date.parse(j['created_at'])
          options[:idx] = j['idx']
          options[:ae] = 'EMRENDOSCOPE'
          options[:station_name] = 'GI'
          options[:model_name] = 'SCOPE-LIFE'
          options[:manufacturer] = 'E.S.M.Solution Co.,Ltd.'
          
          options[:device_sn] = '00000'
          options[:sw_version] = '2.0.1'
          options[:acc] = acc
          options[:study_id] = study_id
          options[:note] = i['title']
          
          options[:study_name] = i['ae'].upcase
          
          puts options.inspect 
          
          convert_dicom fpath, options
          
          
          # convert_dicom_json  j, fpath
          
          
         # `dcmcjpeg --encode-lossless #{dpath} #{dpath}`
         
         
           end

	   unless File.exists?(logpath)
    
    # -xs
    # cmx = "dcmsend -aec #{ae_title} -v #{ae_ip} #{ae_port} #{dpath}"
		cmx = "storescu -v -xe -to 5  -aec #{ae_title} #{ae_ip} #{ae_port} #{dpath}"
    log = `#{cmx}` #dcmsend -aet EMRENDOSCOPE -aec #{ae_title} -v #{ae_ip} #{ae_port} #{dpath}`
    
	  puts cmx
    
		out = File.open(logpath,'w')
	        out.puts cmx
		out.close

	   end

end

      
      
#        end
#     rescue ThreadError
#     end
#   end
# end; "ok"
#
# workers.map(&:join); "ok"



end

sleep 10

end

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
require_relative 'config'


include Magick
include DICOM


require "active_support"
require "eventmachine"
require "active_support/core_ext/date/calculations"
require 'sinatra'
require 'sinatra/base'

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


# ae_title = 'SYNAPSEDICOM'
#
# ae_title = 'ORTHANC'
# ae_ip = '10.5.31.112'
# ae_ip = '10.5.31.68'
# ae_ip = 'localhost'
# ae_port = '4242'

# ae_ip = '10.149.1.42'
# ae_port = '104'
# ae_title = 'KCMH'

# ae_ip = '192.168.0.116'
# ae_port = '104'
# ae_title = 'KCMH'



# host = 'https://gi.emr.med'
# host = 'https://colo.emr-life.com'
# host = 'https://colo.emrlife.com'

ae_title = AE_TITLE
ae_ip = AE_IP
ae_port = AE_PORT
emr_host = HOST
api_path = API_PATH
spec_date = DATE

date = Time.now

date = DateTime.parse(spec_date) if spec_date

# uri = URI("#{host}/colo/Api/get_emr_image?date=#{date}")
uri = URI("#{emr_host}#{api_path}?date=#{date}")


class PACSController < Sinatra::Base
  
  configure do
    
    set :threaded, false
    
    set :queue, []
    
    
  end
  
  get '/' do
    
     'Scope-Life : PACS'
     
  end
  
  
  
  get '/send_report' do
    
    
    q = params
    
    puts "Enqueue #{q.inspect }"
    settings.queue << q
    
    q.to_json
  
    end
  
  
  
end




def send_batch list , emr_host


  storage = "media/dicom"

  ae_title = AE_TITLE
  ae_ip = AE_IP
  ae_port = AE_PORT


for i in list

work_q = Queue.new
puts i
run_stamp = i['created_at'].split("T")[0].gsub('-','/')
index = i['index']


id = i['module_id']
id = i['module_id']['$oid'] if i['module_id'].is_a?(Hash)

sid = "#{i['hn'].split("/").join}-#{i['ae']}-#{i['id']}"

# puts i.inspect
path = File.join(storage,run_stamp,sid)

# stage 1 test folder created

FileUtils.mkdir_p path unless File.exists?(path)

# i['imgs'].each{|x| work_q.push x }
#
#
# workers = (0...4).map do
#   Thread.new do
#     begin
       #
       # while j = work_q.pop(true)
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
        options[:ae] = 'SCOPELIFE'
        options[:station_name] = 'GI-Report'
        options[:model_name] = 'SCOPE-LIFE'
        options[:manufacturer] = 'E.S.M.Solution Co.,Ltd.'
        options[:device_sn] = '00000'
        options[:sw_version] = '2.0.1'
        options[:acc] = acc
        options[:study_id] = study_id
        options[:note] = i['title']
        options[:institution_name] = INSTITUTION_NAME
        options[:study_name] = i['ae'].upcase

        main_options = options

        report_id = i['id']
        report_id = report_id['$oid'] if report_id['$oid']
        i['id'] = report_id
    
    
    
if i['report']

  rpath = File.join(path, "r_#{i['id']}.pdf")

  unless File.exists?(rpath)

  puts 'Generate Report '+i['report']

  report_url = "#{emr_host}/#{i['report']}"
  cmd = "wkhtmltopdf '#{report_url}' #{rpath}"
  out = `#{cmd}`

  report_options = main_options.clone
  report_options[:idx] = 9000
  report_options[:series_uid] = study_id+".9000"
  report_options[:procedure] = 'Report'
  
  # convert pdf to jpg
  
  
  
  ipath = File.join(path, "r_#{i['id']}.jpg")
  cmd = "convert -density 700 #{rpath} -resize 25%  -quality 98 -sharpen 0x1.0 -background white -alpha remove  +adjoin #{ File.join(path, "p_%01d_#{i['id']}.jpg")}"
  
  `#{cmd}`
  
  ls = `ls #{File.join(path, "p_*_#{i['id']}.jpg")}`
  
  pages = ls.split("\n").collect{|x| x.strip }
  
  
  pages.each_with_index do |p,pi|

  report_options[:idx] = pi

  dpath =   p.gsub('jpg','dcm')

  logpath =  p.gsub('jpg','log')

  convert_dicom p, report_options

  
 
  out = File.open(logpath,'w')
  
  if File.exists?(dpath)
 
  cmx = "storescu -v -xe -to 5 -aet SCOPELIFE -aec #{ae_title} #{ae_ip} #{ae_port} #{dpath}"
  log = `#{cmx}` #dcmsend -aet EMRENDOSCOPE -aec #{ae_title} -v #{ae_ip} #{ae_port} #{dpath}`

  puts cmx
  
  out.puts cmx
  out.puts log 
  
  end

  out.close
  
  end  

  end

end


if true



 # Parallel.map(i['imgs'], in_processes: 10) do |j|

 # Parallel.map(i['imgs'], in_processes: 10) do |j|
   for j in i['imgs'] 
         # :[{"id":"657a93cb790f9b2e3b000008","path":"/content/esm/colo/colo/content/colonoscopy/image/657a93cb790f9b2e3b000008.jpg"
         # ,"created_at":"2023-12-14T12:34:03.350+07:00","idx":0}
          begin
         # stage 2 test all image download
          if j['ref'].index('PACS')
           
           fpath = File.join(path, "#{j['id']}.jpg")
           furi = "#{emr_host}#{j['path']}"

           puts "image :  - #{furi} #{j['path']}"
           unless File.exists?(fpath)
             `curl --insecure #{furi} > #{fpath}`
           end

           puts fpath

           dpath = File.join(path, "#{j['id']}.dcm")
           logpath = File.join(path, "#{j['id']}.log")

        if true # unless File.exists?(dpath)

          options = main_options.clone

          options[:hn] = i['hn'].split('/').join('-')
          options[:patient_name] = i['name']
          options[:patient_age] = i['age']
          options[:patient_gender] = i['gender']

          options[:modality] = 'ES'
          options[:study_at] = stamp
          options[:record_at] = Date.parse(j['created_at'])
          options[:idx] = j['idx']
          options[:ae] = 'SCOPELIFE'
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

#        rescue Exception =>e 
 #          puts e.inspect #
#	end


    if true # unless File.exists?(logpath)

    # -xs
    # cmx = "dcmsend -aec #{ae_title} -v #{ae_ip} #{ae_port} #{dpath}"
    cmx = "storescu -v -xe -to 5 -aet SCOPELIFE -aec #{ae_title} #{ae_ip} #{ae_port} #{dpath}"
    log = `#{cmx}` #dcmsend -aet EMRENDOSCOPE -aec #{ae_title} -v #{ae_ip} #{ae_port} #{dpath}`

    puts cmx

    out = File.open(logpath,'w')
          out.puts cmx
          out.puts log
    out.close

     end



    end


  rescue Exception =>e
           puts e.inspect
        end



    end

  end

  end

end


puts uri

def run(opts)

  EM.run do
    
    
    server  = opts[:server] || 'thin'
    host    = opts[:host]   || '0.0.0.0'
    port    = opts[:port]   || '4444'
    web_app = opts[:app]

    Rack::Server.start({
      app:    web_app,
      server: server,
      Host:   host,
      Port:   port,
      signals: false,
    })
    
      EventMachine.add_periodic_timer(5) do
        
        puts "every 10 sec #{INSTITUTION_NAME}"
        
        
        while q = web_app.settings.queue.shift
         

        thr = Thread.new(q) do |q|  
          
            puts q.inspect
            
              params = {}
            
              params[:date] = q[:date]
              params[:id] = q[:id]
              params[:name] = q[:name]
                
    
               emr_host = HOST
               api_path = API_PATH

               date = '2023-12-14'
               date = params[:date] if params[:date]
               rid = "&id=#{params[:id]}" if params[:id]

               lines = File.open('list.tsv').readlines.collect{|i| i.split(" ")}

               puts lines.inspect

               solutions = lines

               solutions = lines.collect{|i| i if i[0] == params[:name]}.compact if params[:name]
               
              puts 'pre'
	      puts solutions.inspect 

               for s in solutions

                 sname, spath = s

                 puts sname +" " + spath


               # uri = URI("#{emr_host}#{api_path}?date=#{date}&id=#{rid}")
               uri = URI("#{spath}?date=#{date}&id=#{rid}")

               emr_host = "#{spath.split('/')[0]}//#{uri.host}"



               puts uri

               http = Net::HTTP.new(uri.host, uri.port)
               http.use_ssl = true
               http.verify_mode = OpenSSL::SSL::VERIFY_NONE

               request = Net::HTTP::Get.new(uri.request_uri)

               response = http.request(request)

               content = response.body

               data = JSON.parse(content)

               

               list = []

               if data['return'] == 200

                 for line in data['data']
                   puts params[:id]
                   puts line.inspect.to_s

                   if params[:id] and ( line['id'] == params[:id] or line['id']['$oid'] == params[:id])

                     list << line

                   else

                     list << line unless params[:id]

                   end

                 end

                  puts list.size

                  send_batch list, emr_host

               end

             end
       
        end    
	            
            
          
        
            
          
        end
     
        
      end
    
    
  end

end

run app: PACSController.new

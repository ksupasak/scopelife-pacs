require 'dicom'
require 'rmagick'
require 'net/http'
require 'net/https'
require 'json'
require 'fileutils'
require 'thread'
require 'parallel'
require 'RMagick'


include Magick
include DICOM

# file = "0002.DCM"
# file = ARGV[0] if ARGV[0]
#
# dcm_template = DICOM::DObject.read(file)
#
# dcm_template.summary
#
#
# dcm_template.to_hash.each_with_index do|k,v|
#   puts "#{k}\t#{v.inspect}"
# end

img_path = '657a93cb790f9b2e3b000008.jpg'

tmp_file = img_path.gsub('jpg','dcm')

`img2dcm #{img_path} #{tmp_file}`


# img_path = 'PRINT.pdf'
#
# tmp_file = img_path.gsub('pdf','dcm')
#
# `pdf2dcm #{img_path} #{tmp_file}`



dcm_template = DICOM::DObject.read(tmp_file)

stamp = Time.now
uix = '1'

sop_uid  =  "#{'1.2.840.1136190195280574824680000700.3.0.1'}.#{uix}"
study_uid = "#{'1.2.840.1136190195280574824680000700.3.0.1'}.#{uix}"

date = stamp.strftime("%Y%m%d")
time = stamp.strftime("%H%M%S")
sop_class_uid = '1.2.840.10008.5.1.4.1.1.7'
hn =  '123456/56'
acc = "#{stamp.strftime("%Y%m%d")}SC#{format('%4d',stamp.to_i)}"
ae = 'EMRENDOSCOPE'
modality = 'ES'
station_name = 'GI'
model_name = 'SCOPE-LIFE'
device_sn = '00000'
sw_version = '2.0.1'



tags = <<EOF
0008,0008	ORIGINAL\\PRIMARY\\EPICARDIAL	Image Type
0008,0018	#{sop_uid}\tSOP UID
0008,0020	#{date}	Study Date
0008,0030	#{time}	Study Time
0008,0032	#{time}	AcquisitionTime Time
0008,0033	#{time}	ContentTime Time
0008,0016	#{sop_class_uid}	SOP Class UID
0008,0055	#{ae}\tAE ttile
0008,0060	#{modality}	Modality
0008,0070	E.S.M.Solution	Manufacturer
0008,0080	EMR-LIFE	Institution Name
0008,1010	#{station_name}	Station Name
0008,1090	#{model_name}\tModel Name
0010,0020\t#{hn}\tPatient's ID
0018,1000	#{device_sn}	Device Serial Number
0018,1020	#{sw_version}	Software Version(s)
0020,0013	1	Instance Number
0020,000D	1.2.840.113619.2.21.848.246800003.0.1952805748.3	Study Instance UID
0020,000E	1.2.840.113619.2.21.24680000.700.0.1952805748.3.0	Series Instance UID
0008,0050\t#{acc}\tAccession Number
0018,1012\t#{date}
0018,1014\t#{time}

EOF

tags = tags.split("\n").collect{|i| i.split("\t")}


for i in tags
  key = i[0]
  value = i[1]
  # 
  if dcm_template[key]
    dcm_template[key].value = value
  else
    dcm_template.add(Element.new(key,value))
  end
  
end
# puts 'xxxx'
# puts ImageList.new(img_path)[0]
#
# img = ImageList.new(img_path)[0]
#
#
#
#
# dcm_template.image = img
# dcm_template['0028,0010'].value = img.rows
# dcm_template['0028,0011'].value = img.columns
# dcm_template['0028,0100'].value = 8



# Study Instance UID
dcm_template['0020,000D'].value = study_uid
# Series Instance UID
dcm_template['0020,000E'].value = "1.2.840.113747.1482742600.10048.17164.60741.0.#{Time.now.to_i}"



# dcm_template['0020,0052'].value  = "1.3.12.2.1107.5.1.4.75506.#{Time.now.to_i}"

# DateOfSecondaryCapture
dcm_template['0018,1012'].value = date
# TimeOfSecondaryCapture
dcm_template['0018,1014'].value = time

# StudyDate
dcm_template['0008,0020'].value = date 
# StudyTime
dcm_template['0008,0030'].value = time


# AcquisitionTime
dcm_template['0008,0032'].value = time
# ContentTime
dcm_template['0008,0033'].value = time


puts "Accession Number = #{dcm_template['0008,0050'].value}"


dcm_template.summary

dcm_template.to_hash.each_with_index do|k,v|
 puts "#{k}\t#{v.inspect}"
end


dcm_template.write(tmp_file)

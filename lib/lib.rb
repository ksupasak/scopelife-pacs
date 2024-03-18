require 'dicom'
require 'rmagick'
include Magick
include DICOM


def convert_dicom img_path, options 
  
  
  puts options.inspect 
  
  type = :img
  type = :pdf if img_path.index("pdf")

  stamp = Time.now
  

  hn =  options[:hn]
  acc = options[:acc]
  ae = options[:ae]
  modality = options[:modality]
  doctor_name = options[:doctor_name]
  doctor_name = "UNKNOWN" unless doctor_name
  
  institution_name = options[:institution_name]
  station_name = options[:station_name]

  model_name = options[:model_name]
  manufacturer = options[:manufacturer]
  device_sn = options[:device_sn]
  sw_version = options[:sw_version]
  
  uix = options[:idx]

  note = options[:note]
  
  sop_instance_rand = Time.now.to_i.to_s

  study_name = options[:study_name]

  
  
  study_date = options[:study_at].strftime("%Y%m%d")
  study_time = options[:study_at].strftime("%H%M%S")
  
  record_date = options[:record_at].strftime("%Y%m%d")
  record_time = options[:record_at].strftime("%H%M%S") 
  
 
  # sop_uid  =  "#{'1.2.840.1136190195280574824680000700.3.0.1'}.#{uix}"
  # study_uid = "#{'1.2.840.1136190195280574824680000700.3.0.1'}.#{uix}"

  date = stamp.strftime("%Y%m%d")
  time = stamp.strftime("%H%M%S")


  sop_class_uid = '1.2.840.10008.5.1.4.1.1.7'
  
  # VL Endoscopic Image Storage
  sop_class_uid = '1.2.840.10008.5.1.4.1.1.77.1.1'
  

  
  # sop_uid  =  "#{'1.2.840.113845.11.1000000001996778014'}.#{sop_instance_rand}.#{uix}"
  
  study_id = options[:study_id]
  study_uid = study_id+".9001"
  series_uid = study_id+".9002"
  series_uid = options[:series_uid] if options[:series_uid]
  
  sop_uid = study_id+".#{uix}"
  
  study_id = acc
  
  patient_name = "ANON0000"
  
  age = ""
  gender = ""
  patient_dob = ""
  
  patient_name = options[:patient_name] if options[:patient_name]
  patient_dob =  options[:patient_dob] if options[:patient_dob]
   
  age = options[:patient_age] if options[:patient_age]
  gender = options[:patient_gender] if options[:patient_gender]
  
  procedure = 'General'
  procedure = options[:procedure] if options[:procedure] 
  
  
  # img_path = 'PRINT.pdf'
  #
  dcm_template = nil
  tmp_file = nil
  
  if type == :img
    
  dcm_template = DICOM::DObject.new
  tmp_file = img_path.gsub('jpg','dcm')
  
  
  elsif type == :pdf
   
    tmp_file = img_path.gsub('pdf','dcm')
    
    tmp_img = img_path.gsub('pdf','jpg')
    
    # `convert -density 700 #{img_path} -resize 25% -append -quality 98 -sharpen 0x1.0 -background white -alpha remove -flatten  #{tmp_img}`
    `convert -density 700 #{img_path} -resize 25%  -quality 98 -sharpen 0x1.0 -background white -alpha remove  +adjoin p_%01d_#{tmp_img}`
    img_path = tmp_img
    
    dcm_template = DICOM::DObject.new
    
    # `pdf2dcm #{img_path} #{tmp_file}`
    #
    # dcm_template = DICOM::DObject.read(tmp_file)
    #
    # # Encapsulated PDF Storage
    #
    # sop_class_uid = '1.2.840.10008.5.1.4.1.1.104.1'
    
  
  end
  #
  # 

  # tmp_file = img_path.gsub('jpg','dcm')
  # puts img_path.inspect
  # endo = ImageList.new(img_path)[0]

  # `img2dcm #{img_path} #{tmp_file}`

  # dcm_template = DICOM::DObject.read(tmp_file)
  
  


  tags = <<EOF
0008,0008\tORIGINAL\\PRIMARY	Image Type
0002,0003\t#{sop_uid}\tSOP UID
0008,0018\t#{sop_uid}\tSOP UID
0020,000D\t#{study_uid}\tStudy Instance UID
0020,000E\t#{series_uid}	Series Instance UID
0020,0010\t#{}
0008,0016\t#{sop_class_uid}	SOP Class UID
0008,0020\t#{study_date}	Study Date
0008,0030\t#{study_time}	Study Time
0008,0032\t#{record_time}	AcquisitionTime Time
0008,0055\t#{ae}\tAE ttile
0008,0060\t#{modality}	Modality
0008,0070\t#{manufacturer}\tE.S.M.Solution	Manufacturer
0008,0080\t#{institution_name}\t	Institution Name
0008,1010\t#{station_name}	Station Name
0008,1090\t#{model_name}\tModel Name
0010,0020\t#{hn}\tPatient's ID
0010,0010\t#{patient_name}\tPatient's Name
0010,0030\t#{patient_dob}\tPatient Birthdate
0010,1010\t#{age}
0010,0040\t#{gender}
0018,1000\t#{device_sn}	Device Serial Number
0018,1020\t#{sw_version}	Software Version(s)
0020,0013\t#{uix}\tInstance Number
0008,0050\t#{acc}\tAccession Number
0018,1012\t#{date}
0018,1014\t#{time}
0008,1030\t#{study_name}
0008,0022\t#{record_date}
0008,0032\t#{record_time}
0008,0023\t#{date}\tContentTime Date
0008,0033\t#{time}\tContentTime Time
0020,4000\t 
0008,1040\t#{station_name}
0040,0254\t#{study_name}
0008,1050\t#{doctor_name}
0018,1030\t#{procedure}
0008,0021\t#{date}
0032,1033\tSYNAPSE DEFAULT
0008,103E\t#{note}
EOF
# 0040,0555\t \t{"Acquisition Context Sequence"=>nil}
# 0008,1111\t \t{"Referenced Performed Procedure Step Sequence"=>nil}
# 0040,0275\t \t{"Request Attributes Sequence"=>nil}
# 0008,2112\t \t{"Source Image Sequence"=>nil}

# Source:               File (successfully read): IM000001
# Modality:             VL Endoscopic Image Storage
# Meta Header:          Yes
# Value Representation: Explicit
# Byte Order (File):    Little Endian
# Pixel Data:           Yes
# Image Size:           1280*1024
# Number of frames:     1
# Photometry:           RGB
# Compression:          No
# Bits per Pixel:       8


# Source:               Created from scratch
# Modality:             VL Endoscopic Image Storage
# Meta Header:          No
# Value Representation: Implicit (Assumed)
# Byte Order (File):    Little Endian (Assumed)
# Pixel Data:           Yes
# Image Size:           1920*1080
# Number of frames:     1
# Photometry:           RGB
# Compression:          No (Assumed)
# Bits per Pixel:       8


# Source:               Created from scratch
# Modality:             VL Endoscopic Image Storage
# Meta Header:          Yes
# Value Representation: Explicit
# Byte Order (File):    Little Endian
# Pixel Data:           Yes
# Image Size:           1920*1080
# Number of frames:     1
# Photometry:           RGB
# Compression:          No
# Bits per Pixel:       8

# I: checking input files ...
# I: Requesting Association
# I: Association Accepted (Max Send PDV: 64222)
# I: Sending file: IM000002
# I: Converting transfer syntax: Little Endian Explicit -> Little Endian Explicit
# I: Sending Store Request (MsgID 1, VLe)
# XMIT: ..............................................................
# I: Received Store Response (Success)
# I: Releasing Association


tags = tags.split("\n").collect{|i| i.split("\t")}

if type == :img or type == :pdf
 
  img_tags = %q(0028,0004 RGB
0028,0002 3
0028,0100 8
0028,0101 8
0028,0102 7
0028,0010 1920
0028,0011 1080
0028,0103 0
0028,0006 0
0028,2110 1
0028,2112 10
0028,2114 ISO_10918_1
0002,0010 1.2.840.10008.1.2.1
0028,0121 
7FE0,0010 
)



tags += img_tags.split("\n").collect{|i| i.split(" ")}
  
end



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


if type == :img or type == :pdf

endo = ImageList.new(img_path)[0]

frame =  endo.columns*endo.rows
columns = endo.columns*3
data = Array.new(frame*3)

   endo.rows.times do |y|
    endo.columns.times do |x|
        pixel = endo.pixel_color(x, y)

        data[y*columns+x*3+0] = pixel.red/256
        data[y*columns+x*3+1] = pixel.green/256
        data[y*columns+x*3+2] = pixel.blue/256

    end
     # puts "#{y}" if y%10==0
   end



  dcm_template['0028,0010'].value = endo.rows
  dcm_template['0028,0011'].value = endo.columns
  

  dcm_template.pixels = data

  
# elsif type == :pdf
    
    
  


end



  puts "Accession Number = #{dcm_template['0008,0050'].value}"


  dcm_template.summary

  dcm_template.to_hash.each_with_index do|k,v|
   puts "#{k}\t#{v.inspect}"
  end
  
  puts "XXXX = #{tmp_file}"
 puts  dcm_template.write(tmp_file)
  
  
  
  
  
  
  
  ##################### OLD
  
  
  
  
  
  
  #
#
# # Load template and image:
# dcm_template = DICOM::DObject.read("template.dcm")
# # dcm_template = DICOM::DObject.read("template.tmp.dcm")
#
# #
# dcm_template.to_hash.each_pair do |k,b|
#
#   puts "#{k}\t\t\t#{b}"
#
# end
#
# acc = "#{stamp.strftime("%Y%m%d")}SC#{format('%4d',stamp.to_i)}"
# uix = "#{stamp.strftime("%Y%m%d")}#{format('%6d',stamp.to_i)}"
#
# endo = ImageList.new(path)[0]
# # endo =
# # now = Time.now
#
# #endo = endo.scale(0.5)
#
# date = stamp.strftime("%Y%m%d")
# time = stamp.strftime("%H%M%S")
#
# # hn = '1234-55'
# uid = '1.2.840.10008.5.1.4.1.1.7'
#
# tags = <<EOF
# 0002,0000  204  File Meta Information Group Length
# 0002,0002  #{uid}  Media Storage SOP Class UID
# 0002,0003  1.2.840.1136190195280574824680000700.3.0.1.19970424140438  Media Storage SOP Instance UID
# 0002,0010  1.2.840.10008.1.2.2  Transfer Syntax UID
# 0002,0012  1.2.276.0.7230010.3.0.3.1.1  Implementation Class UID
# 0002,0013  OFFIS-DCMTK-311  Implementation Version Name
# 0008,0008  ORIGINAL\\PRIMARY\\ENDOSCOPY  Image Type
# 0008,0016  #{uid}  SOP Class UID
# 0008,0018  1.2.840.1136190195280574824680000700.3.0.1.19970424140438  SOP Instance UID
# 0008,0020  #{date}  Study Date
# 0008,0030  #{time}  Study Time
# 0008,0055  EMRENDOSCOPE\tAE ttile
# 0008,0060  #{modality}  Modality
# 0008,0070  E.S.M.Solution  Manufacturer
# 0008,0080  EMR-LIFE  Institution Name
# 0008,1010  GI  Station Name
# 0008,1090  EMR-LIFE Model Name
# 0008,2122  0  Stage Number
# 0008,2124  1  Number of Stages
# 0008,2128  0  View Number
# 0008,212A  1  Number of Views in Stage
# 0010,0010  Anonymized  Patient's Name
# 0010,0020\t#{hn}\tPatient's ID
# 0018,1000  00000  Device Serial Number
# 0018,1020  V1.1  Software Version(s)
# 0020,000D  1.2.840.113619.2.21.848.246800003.0.1952805748.3  Study Instance UID
# 0020,000E  1.2.840.113619.2.21.24680000.700.0.1952805748.3.0  Series Instance UID
# 0020,0011  0  Series Number
# 0020,0013  1  Instance Number
# 0028,0002  3  Samples per Pixel
# 0028,0004  RGB  Photometric Interpretation
# 0028,0006  1  Planar Configuration
# 0028,0010  1920  Rows
# 0028,0011  1080  Columns
# 0028,0100\t8  Bits Allocated
# 0028,0101\t8  Bits Stored
# 0028,0102  7  High Bit
# 0028,0103\t1 Pixel Representation
# EOF
#
# tags = tags.split("\n").collect{|i| i.split("\t")}
#
#
# # Samples per Pixel      3
# # Photometric Interpretation      RGB
# # Planar Configuration      0
# # Rows      1536
# # Columns      2304
# # Bits Allocated      8
# # Bits Stored      8
# # High Bit      7
# # Pixel Representation      0
#
# #rid =       "#{'1.2.840.113845.11.1000000001996778014'}.#{ridx}"
# rid =       "#{'1.2.840.1136190195280574824680000700.3.0.1'}.#{uix}"
# puts "RID #{rid}"
# #0008,0018  1.2.840.1136190195280574824680000700.3.0.1.19970424140438  SOP Instance UID
#
# tags = <<EOF
# 0008,0008  ORIGINAL\\PRIMARY\\EPICARDIAL  Image Type
# 0008,0018  #{rid}\tSOP UID
# 0008,0020  #{date}  Study Date
# 0008,0030  #{time}  Study Time
# 0008,0016  #{uid}  SOP Class UID
# 0008,0055  EMRENDOSCOPE\tAE ttile
# 0008,0060  SC  Modality
# 0008,0070  E.S.M.Solution  Manufacturer
# 0008,0080  EMR-LIFE  Institution Name
# 0008,1010  GI  Station Name
# 0008,1090  EMR-LIFE Model Name
# 0010,0020\t#{hn}\tPatient's ID
# 0018,1000  00000  Device Serial Number
# 0018,1020  V1.1  Software Version(s)
# 0020,0013  1  Instance Number
# 0028,0002  3  Samples per Pixel
# 0028,0004  RGB  Photometric Interpretation
# 0008,0050\t#{acc}\tAccession Number
# 0028,0103\t1 Pixel Representation
# EOF
#
# tags = tags.split("\n").collect{|i| i.split("\t")}
#
# puts "Accession Number = #{dcm_template['0008,0050'].value}"
#
# for i in tags
#   key = i[0]
#   value = i[1]
#   #
#   if dcm_template[key]
#   dcm_template[key].value = value
#   else
#     puts key
#   dcm_template.add(Element.new(key,value))
#   end
#
# end
#
# puts "New Accession Number = #{dcm_template['0008,0050'].value}"
#
#
#
# tags = <<EOF
# 0008,0021  Series Date  DA  1
# 0008,0031  Series Time  TM  1
# 0008,0023  Content Date  DA  1
# 0002,0002  Media Storage SOP Class UID  UI  1
# 0002,0003  Media Storage SOP Instance UID  UI  1
# 0008,0070  Manufacturer  LO  1
# 0008,1150  Referenced SOP Class UID  UI  1
# 0008,1155  Referenced SOP Instance UID  UI  1
# 0008,1030  Study Description  LO  1
# 0008,103E  Series Description  LO  1
# 0008,1060  Name of Physician(s) Reading Study  PN  1-n
# 0008,1080  Admitting Diagnoses Description  LO  1-n
# 0008,1090  Manufacturer's Model Name  LO  1
# 0008,1140  Referenced Image Sequence  SQ  1
# 0010,0010  Patient's Name  PN  1
# 0010,0030  Patient's Birth Date  DA  1
# 0010,0032  Patient's Birth Time  TM  1
# 0010,0040  Patient's Sex  CS  1
# 0010,1010  Patient's Age  AS  1
# 0010,1030  Patient's Weight  DS  1
# 0010,4000  Patient Comments  LT  1
# 0018,0022  Scan Options  CS  1-n
# 0018,0050  Slice Thickness  DS  1
# 0018,0060  KVP  DS  1
# 0018,1030  Protocol Name  LO  1
# 0018,1100  Reconstruction Diameter  DS  1
# 0018,1120  Gantry/Detector Tilt  DS  1
# 0018,1130  Table Height  DS  1
# 0018,1150  Exposure Time  IS  1
# 0018,1151  X-Ray Tube Current  IS  1
# 0018,1152  Exposure  IS  1
# 0018,1160  Filter Type  SH  1
# 0018,1170  Generator Power  IS  1
# 0018,1190  Focal Spot(s)  DS  1-n
# 0018,1210  Convolution Kernel  SH  1-n
# 0018,5100  Patient Position  CS  1
# 0008,0022  Acquisition Date  DA  1
# #0008,0050  Accession Number  SH  1
# #0020,000D  Study Instance UID  UI  1
# #0020,000E  Series Instance UID  UI  1
# #0020,0010  Study ID  SH  1
# #0020,0011  Series Number  IS  1
# #0020,0012  Acquisition Number  IS  1
# #0020,0013  Instance Number  IS  1
# #0020,0052  Frame of Reference UID  UI  1
# 5653,0010  X
# 5653,1014  X
# 5653,1015  X
# 5653,1016  X
# 5653,1017  X
# 5653,1018  X
# 5653,1019  X
# 5653,1022  X
# 5653,1023  X
# 5653,1024  X
# EOF
#
#
# tags = tags.split("\n").collect{|i| i.split("\t")}
#
#
#
# for i in tags
#   key = i[0]
#   value = i[1]
#  # puts dcm_template[key]
#   if key[0]!='#'
#   puts key
#
#
#   dcm_template.delete key
#  end
#
# end
#
#
# #dcm_template.delete '0002,0002'
# #dcm_template.delete '0002,0003'
# #dcm_template.delete '0008,1155'
# # text = Draw.new
# # text.fill = 'White'
# # text.pointsize = 14
# # text.annotate(endo, 0, 0, 10,  endo.rows-40, "Developed by: Soup")
#
#
#
# dcm_template.image = endo
# dcm_template['0028,0010'].value = endo.rows
# dcm_template['0028,0011'].value = endo.columns
# dcm_template['0028,0100'].value = 8
# #puts "### #{dcm_template['0020,000D'].value}"
#
#
#
# # Study Instance UID
# dcm_template['0020,000D'].value = rid
# # Series Instance UID
# dcm_template['0020,000E'].value = "1.2.840.113747.1482742600.10048.17164.60741.0.#{Time.now.to_i}"
#
#
#
# # dcm_template['0020,0052'].value  = "1.3.12.2.1107.5.1.4.75506.#{Time.now.to_i}"
#
# # DateOfSecondaryCapture
# dcm_template['0018,1012'].value = date
# # TimeOfSecondaryCapture
# dcm_template['0018,1014'].value = time
#
# # StudyDate
# dcm_template['0008,0020'].value = date
# # StudyTime
# dcm_template['0008,0030'].value = time
#
# # ContentTime
# dcm_template['0008,0033'].value = time
# # AcquisitionTime
# dcm_template['0008,0032'].value = time
#
#
#
# dcm_template.to_hash.each_with_index do|k,v|
#   puts "#{k}\t#{v.inspect}"
# end
#
# puts dcm_template.inspect
#
# dcm_template.summary
#
#
#
# columns = endo.columns
# data = dcm_template.pixels
#
# puts data.size
#
# #=========================
# #
# # frame =  endo.columns*endo.rows
# #    endo.rows.times do |y|
# #     endo.columns.times do |x|
# #         pixel = endo.pixel_color(x, y)
# #
# #         data[y*columns+x+0] = pixel.red/256
# #         data[y*columns+x+frame] = pixel.green/256
# #         data[y*columns+x+frame*2] = pixel.blue/256
# #         # data[y*columns+x+frame*3] =
# #         # puts pixel.red
# #         # pixel.red
# #         # pixel.green
# #         # pixel.blue
# #         #
# #         # out.pixel_color(x,y,pixel)
# #
# #     end
# #      puts "#{y}" if y%100==0
# # end
# #
# # dcm_template.pixels = data
#
# #=========================
#
# dcm_template.image = endo
#
# #puts rid
#
# # out.write("out-img.jpg")
# # puts dcm.methods.sort
#
# # dcm_template.image_from_file 'endo.jpg'
#
# # Modality:             Ultrasound Image Storage
# # Meta Header:          Yes
# # Value Representation: Explicit
# # Byte Order (File):    Big Endian
# # Pixel Data:           Yes
# # Image Size:           640*480
# # Number of frames:     1
# # Photometry:           RGB
# # Compression:          No
# # Bits per Pixel:       8
#
# # puts
# #
#
# #
# dcm_template.summary
# # puts dcm.to_hash.inspect
# puts path.gsub('jpg','dcm')
#
# dcm_template.write(path.gsub('jpg','dcm'))
# puts 'Complete in tmp'
# puts rid



end

# `/usr/local/opt/imagemagick@6/bin/convert out.dcm out.jpg`
# `open out.jpg`

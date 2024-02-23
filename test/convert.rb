require 'dicom'
require 'RMagick'
include Magick
include DICOM


# Load template and image:
dcm_template = DICOM::DObject.read("t.dcm")

endo = ImageList.new("657a93cb790f9b2e3b000008.jpg")[0] 

now = Time.now
date = now.strftime("%Y.%m.%d")
time = now.strftime("%H:%M:%S")
hn = '4572458'
uid = '1.2.840.10008.5.1.4.1.1.7'

tags = <<EOF
0002,0000	204	File Meta Information Group Length
0002,0002	#{uid}	Media Storage SOP Class UID
0002,0003	1.2.840.1136190195280574824680000700.3.0.1.19970424140438	Media Storage SOP Instance UID
0002,0010	1.2.840.10008.1.2.2	Transfer Syntax UID
0002,0012	1.2.276.0.7230010.3.0.3.1.1	Implementation Class UID
0002,0013	OFFIS-DCMTK-311	Implementation Version Name
0008,0008	ORIGINAL\\PRIMARY\\EPICARDIAL	Image Type
0008,0016	#{uid}	SOP Class UID
0008,0018	1.2.840.1136190195280574824680000700.3.0.1.19970424140438	SOP Instance UID
0008,0020	#{date}	Study Date
0008,0030	#{time}	Study Time
0008,0060	SC	Modality
0008,0070	E.S.M.Solution	Manufacturer
0008,0080	EMR-LIFE	Institution Name
0008,1010	gi	Station Name
0008,1090	EMR-LIFE Model Name
0008,2122	0	Stage Number
0008,2124	1	Number of Stages
0008,2128	0	View Number
0008,212A	1	Number of Views in Stage
0010,0010	Anonymized	Patient's Name
0010,0020\t#{hn}\tPatient's ID
0018,1000	00000	Device Serial Number
0018,1020	V1.1	Software Version(s)
0020,000D	1.2.840.113619.2.21.848.246800003.0.1952805748.3	Study Instance UID
0020,000E	1.2.840.113619.2.21.24680000.700.0.1952805748.3.0	Series Instance UID
0020,0011	0	Series Number
0020,0013	1	Instance Number
0028,0002	3	Samples per Pixel
0028,0004	RGB	Photometric Interpretation
0028,0006	1	Planar Configuration
0028,0010	1920	Rows
0028,0011	1080	Columns
0028,0100\t8	Bits Allocated
0028,0101\t8	Bits Stored
0028,0102	7	High Bit
0028,0103\t1 Pixel Representation
EOF

tags = tags.split("\n").collect{|i| i.split("\t")}



for i in tags
  key = i[0]
  value = i[1] 
  dcm_template.add(Element.new(key,value))
end


text = Draw.new
text.fill = 'White'
text.pointsize = 14
text.annotate(endo, 0, 0, 10,  endo.rows-40, "Developed by: Soup")



dcm_template.image = endo
dcm_template['0028,0010'].value = endo.rows
dcm_template['0028,0011'].value = endo.columns
dcm_template['0028,0100'].value = 8

dcm_template.summary

columns = endo.columns
data = dcm_template.pixels

puts data.size



# frame =  endo.columns*endo.rows
#    endo.rows.times do |y|
#     endo.columns.times do |x|
#         pixel = endo.pixel_color(x, y)
#
#         data[y*columns+x+0] = pixel.red/256
#         data[y*columns+x+frame] = pixel.green/256
#         data[y*columns+x+frame*2] = pixel.blue/256
#         # data[y*columns+x+frame*3] =
#         # puts pixel.red
#         # pixel.red
#         # pixel.green
#         # pixel.blue
#         #
#         # out.pixel_color(x,y,pixel)
#
#     end
#      puts "#{y}" if y%10==0
# end
#
# dcm_template.pixels = data

# out.write("out-img.jpg")
# puts dcm.methods.sort

# dcm_template.image_from_file endo

# Modality:             Ultrasound Image Storage
# Meta Header:          Yes
# Value Representation: Explicit
# Byte Order (File):    Big Endian
# Pixel Data:           Yes
# Image Size:           640*480
# Number of frames:     1
# Photometry:           RGB
# Compression:          No
# Bits per Pixel:       8

# puts
#
# puts dcm_template.to_hash.inspect
#
dcm_template.summary
# puts dcm.to_hash.inspect

dcm_template.write("out.dcm")


dcm_template.to_hash.each_with_index do|k,v|
 puts "#{v}\t#{k[0]}\t#{k[1]}"
 
 # map[k[0]]=[k[1],"NA"] unless map[k[0]]
 
 
end

# `/usr/local/opt/imagemagick@6/bin/convert out.dcm out.jpg`
# `open out.jpg`
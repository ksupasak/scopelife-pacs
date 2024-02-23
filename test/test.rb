require_relative 'lib'

acc = ''
#acc = '20190109SC0001'
#acc = '20161226CT0065'

hn = "#{Time.now.strftime("%Y%m%d001")}"
convert_dicom hn, 'SC', 'sample.jpg', Time.now, Time.now.to_i.to_s, acc
puts '=================================='
puts
dcm = DICOM::DObject.read('sample.dcm')
puts 

dcm.summary

`dcmcjpeg   --encode-lossless sample.dcm sample.dcm`

#`dcmsend -aet EMRENDOSCOPE -aec SYNAPSEDICOM -v 10.5.31.112 104 sample.dcm`




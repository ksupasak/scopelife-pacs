require 'dicom'
include DICOM


#node = DClient.new("10.5.31.112", 104, :host_ae=>'SYNAPSEDICOM')

node = DClient.new("localhost", 104)

node.echo 

node.send("sample.dcm")

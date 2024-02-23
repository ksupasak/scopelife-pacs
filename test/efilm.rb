require 'dicom'
require 'rmagick'
require 'net/http'
require 'net/https'
require 'json'
require 'fileutils'
require 'thread'
require 'parallel'
require 'RMagick'
require "csv"

include Magick
include DICOM

elmap = {}

elements = CSV.read("elements.tsv", col_sep: "\t")
for i in elements
  
  elmap[i[1]] = i[0]
  
  
end

# puts elements.inspect
puts elmap.inspect 


dcm_path = 'IM000001'
dcm2_path = '657a93cb790f9b36a1000001.dcm'
dcm2_path = '/Users/soup/Desktop/pacs/production/dicom/emr-dicom/media/dicom/2024/01/19/657a93ae790f9b2e3b000007/657a93cb790f9b2e3b000008.dcm'
dcm2_path = 'out.dcm'





dcm_template = DICOM::DObject.read(dcm_path)
dcm2_template = DICOM::DObject.read(dcm2_path)
# dcm3_template = DICOM::DObject.read(dcm3_path)
#
# dcm3_template.to_hash.each_with_index do|k,v|
#  puts "#{v}\t#{k[0]}\t#{k[1]}"
#
#  # map[k[0]]=[k[1],"NA"] unless map[k[0]]
#
#
# end
#
#



#
puts dcm_template.summary
puts dcm_template.pixels.size

# puts
#
# puts dcm_template.to_hash
# puts
#
# map = {}
#
# dcm_template.to_hash.each_with_index do|k,v|
#
#  puts "#{v}\t#{k[0]}\t#{k[1]}"
#
#  map[k[0]]=[k[1],"NA"] unless map[k[0]]
#
#
# end
#
#
# dcm2_template.to_hash.each_with_index do|k,v|
#  puts "#{v}\t#{k[0]}\t#{k[1]}"
#
#  if map[k[0]]
#    map[k[0]][1] = k[1]
#  else
#
#    map[k[0]] = ["NA", k[1]]
#
#   end
#
# end
#
#
#
# for k in map.keys.sort
#
#   el = elmap[k]
#   el = '----,----' unless el
#   puts "#{el}\t#{k}\t#{map[k][0]}\t#{map[k][1]}"
# end


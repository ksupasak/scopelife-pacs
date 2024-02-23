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


endo = ImageList.new("657a93cb790f9b2e3b000008.jpg")[0] 



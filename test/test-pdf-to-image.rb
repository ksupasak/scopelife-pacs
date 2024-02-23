require 'RMagick'
pdf = Magick::ImageList.new("r_657a93db790f9b36cf000008.pdf").each_with_index { |img, i|

# pdf.write('pdf_to_img.jpg')


  # img.resize_to_fit!(21*720, 29*720)

  img.write("pdf_to_img.jpg") {
    # self.quality = 80
    self.density = '300'
    # self.colorspace = Magick::RGBColorspace
    # self.interlace = Magick::NoInterlace
  }
  
}

# convert -density 700 r_657a93db790f9b36cf000008.pdf -resize 25% -append -quality 98 -sharpen 0x1.0 -background white -alpha remove -flatten  24-11.jpg
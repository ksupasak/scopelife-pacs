from pythainlp.transliterate import romanize
import sys
# text = "ศุภศักดิ์ กุลวงศ์อนันชัย"
th_name = sys.argv[1]

en_name = romanize(th_name, engine="royin" )
print(en_name)
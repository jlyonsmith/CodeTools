File.open("cr.txt", 'w') { |f| f.write("\r") }
File.open("lf.txt", 'w') { |f| f.write("\n") }
File.open("crlf.txt", 'w') { |f| f.write("\r\n") }
File.open("mixed1.txt", 'w') { |f| f.write("\n\r\n\r") }
File.open("mixed2.txt", 'w') { |f| f.write("\n\n\r\n\r") }
File.open("mixed3.txt", 'w') { |f| f.write("\n\r\n\r\r") }
File.open("mixed4.txt", 'w') { |f| f.write("\n\r\n\r\r\n") }

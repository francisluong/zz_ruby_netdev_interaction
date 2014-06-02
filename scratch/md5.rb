#!/usr/bin/env ruby

if (ARGV.length == 0) then
  puts "Usage: md5.rb <version>"
  exit
end
pass = "PASS"
version = ARGV[0].strip
files_list = Dir.glob("*#{version}*.tgz")
files_list.each do|filename|
  filename = File.expand_path(filename)
  puts "filename: #{filename}"
  this_md5 = %x(env md5 #{filename}).split(' ')[-1]
  expected_md5 = %x(cat #{filename}.md5).strip
  puts "this_md5: '#{this_md5}'"
  puts "expected: '#{expected_md5}'"
  print "==> "
  if (this_md5.eql? expected_md5) then
    puts "PASS"
  else 
    puts "FAIL"
    pass = "FAIL"
  end
  puts "====================="
end
puts "All Files Passed? ==> #{pass}"

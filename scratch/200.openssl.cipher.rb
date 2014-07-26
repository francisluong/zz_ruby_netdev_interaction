#!/usr/bin/ruby

require "openssl"
require "#{File.expand_path(File.dirname(__FILE__))}/lp.rb"

lp = Lineprinter.new

###
lp.printline
lp.h1("Ciphers")
puts OpenSSL::Cipher.ciphers
cipher = OpenSSL::Cipher.new('AES-256-CBC')
decipher = OpenSSL::Cipher.new('AES-256-CBC')
cipher.encrypt
decipher.decrypt
decipher.key = cipher.random_key
decipher.iv = cipher.random_iv

data = "Super Secret Squirrel!!!"

lp.h1("Data")

    lp.h2("Raw")
    puts data

    lp.h2("Encrypted")
    encrypted = cipher.update(data) + cipher.final
    puts "Match data == encrypted: #{data == encrypted}"

    lp.h2("Decrypted")
    decrypted = decipher.update(encrypted) + decipher.final
    puts decrypted
    puts "Match data == decrypted: #{data == decrypted}"

lp.h1("Second String")
    data = "Second Secret Squirrel!!!"
    cipher.encrypt
    decipher.decrypt

    lp.h2("Raw")
    puts data

    lp.h2("Encrypted")
    encrypted = cipher.update(data) + cipher.final
    puts "Match data == encrypted: #{data == encrypted}"

    lp.h2("Decrypted")
    decrypted = decipher.update(encrypted) + decipher.final
    puts decrypted
    puts "Match data == decrypted: #{data == decrypted}"


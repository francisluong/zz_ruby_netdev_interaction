#!/bin/bash
if [ ! -f $1.rb ]; then 
  cp 000.rb $1.rb	
fi
vim $1.rb

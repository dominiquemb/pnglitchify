#!/usr/bin/ruby 

require 'optparse'
require 'pnglitch'
require 'find'

# filter types:
# 0 = None
# 1 = Sub
# 2 = Up
# 3 = Average
# 4 = Paeth

# method types:
# 0 = replace
# 1 = transpose
# 2 = defect

# interlace options:
# true
# false

# alpha options:
# true
# false

# compress options:
# true
# false

filters = {'optimized' => 0, 'sub' => 1, 'up' => 2, 'average' => 3, 'paeth' => 4}
methods = {'replace' => 0, 'transpose' => 1, 'defect' => 2}

count = 0

options = Hash.new
currentArg = false

# collect arguments
ARGV.each do |arg|
    if arg.index('--') == 0
        key = arg.split('--')[1]
        currentArg = key
        options[key] = []
    elsif arg.index('-') == 0
        key = arg.split('-')[1]
        currentArg = key
        options[key] = []
    else 
        if currentArg
            options[currentArg] << arg
        end
    end
end

infiles = []
interlace = false
compress = false
alpha = false
filter = filters[0]
method = methods[0]
directory = ""

p 'options'
p options

def findFilesRecursively(currentdir, filearray)
    unless currentdir.index('/') == (currentdir.length-1)
        currentdir = currentdir + '/'
    end
    dirfiles = Dir[currentdir + "*png"]
    dirfiles = Dir[currentdir + "*png"]
    filearray.concat dirfiles
end

# parse arguments
options.keys.each_with_index do |key, index|
    if key == 'p' || key == 'pngfiles' 
        infiles = options[key]
    elsif key == 'd' || key == 'dir'
        directory = options[key][0]

        unless directory.index('/') == (directory.length-1)
            directory = directory + '/'
        end
#        infiles = Dir[directory + "*png"]
        Find.find(directory) do |path|
            if path.index(".png") == (path.length-4) || path.index(".PNG") == (path.length-4)
                if path.index("pnglitchified").nil?
                    infiles << path
                end
            end
        end
    elsif key == 'f' || key == 'filter'
        chosenfilter = options[key][0]
        if chosenfilter == 'random'
            filter = filters[filters.keys.sample]
        else
            filter = filters[chosenfilter]
        end
    elsif key == 'm' || key == 'method'
        chosenmethod = options[key][0]
        if chosenmethod == 'random'
            method = methods[methods.keys.sample]
        else
            method = methods[chosenmethod]
        end
    elsif key == 'a' || key == 'alpha'
        alpha = true
    elsif key == 'c' || key == 'compress'
        compress = true
    elsif key == 'i' || key == 'interlace'
        interlace = true
    elsif key == 'r' || key == 'random'
        filter = filters[filters.keys.sample]
        method = methods[methods.keys.sample]
        alpha = [true, false].sample
        compress = [true, false].sample
        interlace = [true, false].sample
    end
end

=begin
p 'filter'
p filter
p 'method'
p method
p 'alpha'
p alpha
p 'compress'
p compress
p 'interlace'
p interlace
=end

p 'infiles'
p infiles

infiles.each do |infile|
    begin
        unless infile.index('.png').nil?
            original_infile = infile.split('.png')[0]
        end
        unless infile.index('.PNG').nil?
            original_infile = infile.split('.PNG')[0]
        end

        if interlace
            p "interlace"
            system("convert -interlace plane %s %stmp.png" % [infile, directory])
            infile = directory + 'tmp.png'
            p "directory"
            p directory
        end

        PNGlitch.open(infile) do |p|
            buf = 2 ** 18
            p.change_all_filters filter unless filter == filters['optimized']

            options = [filter.to_s]
            options << 'alpha' if alpha
            options << 'interlace' if interlace
            options << 'compress' if compress
            options << method.to_s
            process = Proc.new{|data, range|
                case method
                when methods['replace']
                    range.times do
                        data[rand(data.size)] = 'x'
                    end
                    data
                when methods['transpose']
                    x = data.size / 4
                    data[0, x] + data[x * 2, x] + data[x * 1, x] + data[x * 3..-1]
                when methods['defect']
                    (range / 5).times do
                        data[rand(data.size)] = ''
                    end
                    data
                end
            }
            unless compress 
                p.glitch do |data|
                    process.call data, 50
                end
            else 
                p.glitch_after_compress do |data|
                    process.call data, 10
                end
            end

            #outfile = "pnglitch-%03d-%s.png" % [count, options.join('-')]
            outfile = "%s_pnglitchified.png" % [original_infile]
            p 'outfile'
            p outfile
            p.save outfile
            p.close

            # deleting temporary files
            File.delete(directory + 'tmp.png') if File.exists?(directory + 'tmp.png')

            #p.each_scanline do |scanline|
            #    scanline.change_filter filter
            #end
            #p.glitch_as_io do |io|
            #    until io.eof? do
            #        d = io.read(buf)
            #        io.pos -= d.size
            #        io.print(d.gsub(/\d/, 'x'))
            #    end
            #end
            #p.save 'dashboard_iphone_glitched.png'
        end
    rescue
        p 'error?'
        # if there's an error opening the file, just skip it
    end
end

#File.unlink 'tmp.png'

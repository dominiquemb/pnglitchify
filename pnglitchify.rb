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
methods = {'replace' => 0, 'transpose' => 1, 'defect' => 2, 'graft' => 3}

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
chosenfilter = false
chosenincorrectfilter = false
method = methods[0]
incorrectfilter = false
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
    elsif key == 'I' || key == 'incorrect'
        chosenincorrectfilter = options[key][0]
        if chosenincorrectfilter == 'random'
            incorrectfilter = rand(0..4)
        else
            incorrectfilter = chosenincorrectfilter
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
    #begin
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

        p 'before open'
        PNGlitch.open(infile) do |p|
            buf = 2 ** 18

            unless incorrectfilter
                p.change_all_filters filter unless filter == filters['optimized']
            else
                if chosenfilter
                    p.each_scanline do |l|
                        l.graft filter
                    end
                end

                p "incorrect filter: "
                p incorrectfilter
                if incorrectfilter == 1 || incorrectfilter == "1"
                    p.each_scanline do |l|
                        l.register_filter_encoder do |data, prev|
                            data.size.times.reverse_each do |i|
                                x = data.getbyte(i)
                                v = prev ? prev.getbyte(i - 1) : 0
                                data.setbyte(i, (x - v) & 0xff)
                            end
                            data
                        end
                    end
                end
                if incorrectfilter == 2 || incorrectfilter == "2"
                    p.change_all_filters 4
                    p.each_scanline do |l|
                        l.register_filter_encoder do |data, prev|
                            data.size.times.reverse_each do |i|
                                x = data.getbyte(i)
                                v = prev ? prev.getbyte(i - 6) : 0
                                data.setbyte(i, (x - v) & 0xff)
                            end
                            data
                        end
                    end
                end
                if incorrectfilter == 3 || incorrectfilter == "3"
                    p.change_all_filters 4
                    sample_size = p.sample_size
                    result = ""
                    p.each_scanline do |l|
                        l.register_filter_encoder do |data, prev|
                            data.size.times.reverse_each do |i|
                                x = data.getbyte i
                                is_a_exist = i >= sample_size
                                is_b_exist = !prev.nil?
                                a = is_a_exist ? data.getbyte(i - sample_size) : 0
                                b = is_b_exist ? prev.getbyte(i) : 0
                                c = is_a_exist && is_b_exist ? prev.getbyte(i - sample_size) : 0
                                z =  a + b - c
                                za = (z - a).abs
                                zb = (z - b).abs
                                zc = (z - c).abs
                                zr = za <= zb && za <= zc ? a : zb <= zc ? b : c
                                data.setbyte i, (x - zr) & 0xfe
                            end
                            data
                        end
                    end
                end
                if incorrectfilter == 4 || incorrectfilter == "4"
                    p.change_all_filters 2
                    p.each_scanline do |l|
                        l.register_filter_encoder do |data, prev|
                            data.size.times.reverse_each do |i|
                                x = data.getbyte(i)
                                v = prev ? prev.getbyte(i) : 0
                                data.setbyte(i, (x - v) & 0xfe)
                            end
                            data
                        end
                    end
                end
            end
                
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
                    when methods['graft']
                        p.each_scanline do |line|
                            line.graft rand(5)
                        end
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

            unless incorrectfilter
                p.save outfile
                p.close
            else
                p.output outfile
                p.close
            end

            # deleting temporary files
            File.delete(directory + 'tmp.png') if File.exists?(directory + 'tmp.png')
        end
    #rescue
    #    p 'error?'
        # if there's an error opening the file, just skip it
    #end
end

#File.unlink 'tmp.png'

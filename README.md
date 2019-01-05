# Pnglitchify
Automates rapid glitching of multiple PNG files using the [pnglitch gem](https://ucnv.github.io/pnglitch/).

# Dependencies
    gem install pnglitch
    
# Install Ruby
Ruby 2.3.1 is recommended

    sudo apt-get install ruby
    
# Install pnglitchify
    git clone https://github.com/dominiquemb/pnglitchify.git
    cd pnglitchify
    sudo chmod +x pnglitchify
    
# How to use
    ./pnglitchify [OPTIONS]

# Available options
-d or --dir

-p or --pngfiles

-a or --alpha

-c or --compress

-i or --interlace

-r or --random

# Available filters
optimized, sub, up, average, paeth

# "Incorrect" filters

For more information on incorrect filters, see Appendix C of the pnglitch guide: https://ucnv.github.io/pnglitch/

There are 4 different incorrect filters available. Basic examples below:

    ./pnglitchify.rb -p png_name_here.png --incorrect 1
    ./pnglitchify.rb -p png_name_here.png --incorrect 2
    ./pnglitchify.rb -p png_name_here.png --incorrect 3
    ./pnglitchify.rb -p png_name_here.png --incorrect 4
    
You can also use the shorthand -I instead of --incorrect:

    ./pnglitchify.rb -p png_name_here.png -I 3
    
It is possible to combine incorrect filters with any method type, as well as options such as alpha, interlace, and compress:

    ./pnglitchify.rb -p png_name_here.png --incorrect 3 --method transpose --interlace --compress
    ./pnglitchify.rb -p png_name_here.png --incorrect 3 --method defect --interlace --compress
    ./pnglitchify.rb -p png_name_here.png --incorrect 3 --method replace --interlace --compress
    
Also, it's possible to combine incorrect filters with 'correct' filter types, such as optimized, sub, up, avergae and paeth. Examples below:

    ./pnglitchify.rb -p png_name_here.png --incorrect 3 --filter optimized --method transpose --interlace --compress
    ./pnglitchify.rb -p png_name_here.png --incorrect 3 --filter sub --method transpose --interlace --compress
    ./pnglitchify.rb -p png_name_here.png --incorrect 3 --filter up --method transpose --interlace --compress
    ./pnglitchify.rb -p png_name_here.png --incorrect 3 --filter average --method transpose --interlace --compress
    ./pnglitchify.rb -p png_name_here.png --incorrect 3 --filter paeth --method transpose --interlace --compress

# Available methods
transpose, defect, replace

# Examples
Run recursively on a specified directory (in this case it's "."):

    ./pnglitchify.rb --dir . 

Specify input files manually:

    ./pnglitchify.rb --pngfiles example1.png example2.png 

Completely randomize all options:

    ./pnglitchify.rb --dir . --random
    
Randomize only filter:

    ./pnglitchify.rb --dir . --filter "random"
    
Randomize only method:

    ./pnglitchify.rb --dir . --method "random"
    
Enable alpha:
    ./pnglitchify.rb --dir . --alpha
    
Enable compress:

    ./pnglitchify.rb --dir . --compress
    
Enable interlace:

    ./pnglitchify.rb --dir . --interlace
    
More complete example:

    ./pnglitchify.rb --dir . --filter "paeth" --method "defect" --alpha --compress --interlace
    
# Saved output
Output files have the following naming format: (original_name)_pnglitchified.png

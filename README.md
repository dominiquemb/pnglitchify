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

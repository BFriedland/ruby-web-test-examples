
require 'inifile'


module SeleniumUtilities

    # Reference for mixins, including reasoning on include vs. extend:
    # http://stackoverflow.com/a/549273

    # Example use:
    # record_video_toggle =
    #     find_subelements_with_text("tag_name", "label", "Record Video")
    def find_subelements_with_text(findable_type, findable_name, text)

        # Note that @driver means this utility depends on
        # being a mixin for a class that has a driver attribute.
        elements = @driver.find_elements findable_type.to_sym, findable_name

        found_elements = []

        elements.each do |each_subelement|
            if each_subelement.text == text
                found_elements << each_subelement
            end
        end

        if found_elements.length == 1
            return found_elements[0]
        elsif found_elements.length == 0
            return []
        end

    end

    # This method is not used by the tests,
    # but it did help with creating them.
    # Example use:
    # find_elements_and_print_text("class", "hljs-ruby")
    def find_elements_and_print_text(findable_attribute, findable_name)

        elements = @driver.find_elements findable_attribute.to_sym, findable_name

        elements.each do |each_subelement|
            puts "#{each_subelement.text}"
        end

    end

end


module IniFileUtilities

    # inifile source and docs:
    # https://github.com/TwP/inifile

    def load_and_flatten_ini_file

        loaded_ini_file = IniFile.load('./configuration.ini')

        # Remove unnecessary section titles, store in class attribute:
        @ini_file = Hash.new
        loaded_ini_file.each do |section|
            loaded_ini_file[section].each do |each_key_value_pair|
                key = each_key_value_pair[0]
                value = each_key_value_pair[1]
                @ini_file[key] = value
            end
        end

        generate_implied_data

    end

    # After the file is loaded, we should add a few pieces
    # of data that the configuration file is not required
    # to contain (because these data are necessarily
    # implied by what is required).
    def generate_implied_data

        if @ini_file['device'].downcase == "pc" or
            @ini_file['device'].downcase == "mac" then

                @ini_file['device_category'] = "Desktop"

        elsif @ini_file['device'].downcase.include? "iphone" or
            @ini_file['device'].downcase.include? "ipad" then

                @ini_file['device_category'] = "iOS"

        else
            # Noncompliant ini input is
            # going to be "Android" today.
            @ini_file['device_category'] = "Android"

        end

    end

end

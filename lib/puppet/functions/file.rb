# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
# Returns the contents of a file
# ---- original file header ----
#
# @summary
#   Return the contents of a file.  Multiple files
#        can be passed, and the first file that exists will be read in.
#
Puppet::Functions.create_function(:'file') do
  # @param vals
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :vals
  end


  def default_impl(*vals)
    
            ret = nil
            vals.each do |file|
                unless file =~ /^#{File::SEPARATOR}/
                    raise Puppet::ParseError, "Files must be fully qualified"
                end
                if FileTest.exists?(file)
                    ret = File.read(file)
                    break
                end
            end
            if ret
                ret
            else
                raise Puppet::ParseError, "Could not find any files from %s" %
                    vals.join(", ")
            end

  end
end

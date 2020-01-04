# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
# Test whether a given class or definition is defined
# ---- original file header ----
#
# @summary
#   Determine whether a given
#    type is defined, either as a native type or a defined type, or whether a class is defined.
#    This is useful for checking whether a class is defined and only including it if it is.
#    This function can also test whether a resource has been defined, using resource references
#    (e.g., ``if defined(File['/tmp/myfile']) { ... }``).  This function is unfortunately
#    dependent on the parse order of the configuration when testing whether a resource is defined.
#
Puppet::Functions.create_function(:'defined') do
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
    
        result = false
        vals.each do |val|
            case val
            when String
                # For some reason, it doesn't want me to return from here.
                if Puppet::Type.type(val) or find_definition(val) or find_hostclass(val)
                    result = true
                    break
                end
            when Puppet::Parser::Resource::Reference
                if findresource(val.to_s)
                    result = true
                    break
                end
            else
                raise ArgumentError, "Invalid argument of type %s to 'defined'" % val.class
            end
        end
        result

  end
end
# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----

# ---- original file header ----
#
# @summary
#   Evaluate a template and return its value.  See `the templating docs
#    </trac/puppet/wiki/PuppetTemplating>`_ for more information.  Note that
#    if multiple templates are specified, their output is all concatenated
#    and returned as the output of the function.
#
Puppet::Functions.create_function(:'template') do
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
    
        require 'erb'

        vals.collect do |file|
            # Use a wrapper, so the template can't get access to the full
            # Scope object.
            debug "Retrieving template %s" % file

            wrapper = Puppet::Parser::TemplateWrapper.new(self)
            wrapper.file = file
            begin
                wrapper.result
            rescue => detail
                raise Puppet::ParseError,
                    "Failed to parse template %s: %s" %
                        [file, detail]
            end
        end.join("")

  end
end

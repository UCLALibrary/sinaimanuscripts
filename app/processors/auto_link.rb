# frozen_string_literal: true
# Joins values using configured value, linebreak, or delimiter
class AutoLink < Blacklight::Rendering::AbstractStep
  include ActionView::Helpers::TextHelper

  def render
    if config.auto_link
        linkedValues = values.map do |value| 
            auto_link(html_escape(value)) do |text|
                "#{text }"
            end
        end  
        next_step(linkedValues)
    else
        next_step(values)
    end
    
  end

  def html_escape(*args)
    ERB::Util.html_escape(*args)
  end
end

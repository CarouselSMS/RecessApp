module Simplabs #:nodoc:

  module ReportsAsSparkline #:nodoc:

    module SparklineTagHelper

      # Renders a sparkline with the given data.
      #
      # ==== Parameters
      #
      # * <tt>data</tt> - The data to render the sparkline for, is retrieved from a report like <tt>User.registration_report</tt>
      #
      # ==== Options
      #
      # * <tt>width</tt> - The width of the generated image
      # * <tt>height</tt> - The height of the generated image
      # * <tt>line_color</tt> - The line color of the sparkline (hex code)
      # * <tt>fill_color</tt> - The color to fill the area below the sparkline with (hex code)
      # * <tt>labels</tt> - The axes to render lables for (Array of <tt>:x</tt>, <tt>:y+</tt>, <tt>:r</tt>, <tt>:t</tt>; this is x axis, y axis, right, top)
      #
      # ==== Example
      # <tt><%= sparkline_tag(User.registrations_report, :width => 200, :height => 100, :color => '000') %></tt>
      def sparkline_tag(data, options = {})
        options.reverse_merge!({ :width => 300, :height => 34, :thickness => 1, :line_color => '0077cc', :fill_color => 'e6f2fa', :labels => [] })
        data = data.collect { |d| d[1] }
        labels = ""
        unless options[:labels].empty?
          labels = "&chxt=#{options[:labels].map(&:to_s).join(',')}&chxr=0,0,#{data.length}|1,0,#{data.max}|2,0,#{data.max}|3,0,#{data.length}"
        end
        image_tag(
          "http://chart.apis.google.com/chart?cht=ls&chs=#{options[:width]}x#{options[:height]}&chd=t:#{data.join(',')}&chco=#{options[:line_color]}&chm=B,#{options[:fill_color]},0,0,0&chls=#{options[:thickness]},0,0&chds=#{data.min},#{[data.max, 1].max}#{labels}",
          :size => "#{options[:width]}x#{options[:height]}"
        )
      end

    end

  end

end

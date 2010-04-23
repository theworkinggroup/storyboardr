require 'sinatra/base'
require 'fastercsv'
require 'lib/extensions'
require 'prawn'
require 'prawn/layout'

class StoryPrinter < Sinatra::Base
  
  get '/' do
    erb :index
  end
  
  post '/' do
    filename = params[:file][:filename]
    file = params[:file][:tempfile]
    
    @stories = []
    data = FasterCSV.parse(file)
    data.each do |project, type, story, estimate|
      @stories << {
        :project  => project,
        :type     => type,
        :story    => story,
        :estimate => estimate
      }
    end
    # erb :output
    pdf = ::Prawn::Document.new
    items = @stories.map do |story|
      [
        story[:project],
        story[:type],
        story[:story],
        story[:estimate]
      ]
    end
    
    pdf.font 'Helvetica', :size => 10
    pdf.table items, 
      :border_style => :grid,
      :row_colors   => ["FFFFFF","DDDDDD"],
      :align        => { 0 => :left, 1 => :left, 2 => :left, 3 => :left },
      :font_size    => 7
    content_type 'application/pdf'
    pdf.render
  end
  
end
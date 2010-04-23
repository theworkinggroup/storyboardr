require 'sinatra/base'
require 'fastercsv'
require 'pp'
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
    
    data = FasterCSV.parse(file)
    @stories = data.collect do |project, type, story, estimate|
       {
        :project  => project,
        :type     => type,
        :story    => story,
        :estimate => estimate
      }
    end
    
    # erb :output
    pdf = ::Prawn::Document.new(:margin => 0)
    pdf.font 'Helvetica', :size => 10
    @stories.in_groups_of(8, false) do |page|
      page.in_groups_of(2, false) do |row|
        pdf.text row[0][:project]
        
                
      end
      
    end
    
    
        
        
    content_type 'application/pdf'
    attachment 'test.pdf'
    pdf.render
  end
  
end
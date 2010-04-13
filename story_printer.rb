require 'rubygems'
require 'sinatra/base'
require 'fastercsv'
require 'lib/extensions'

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
    erb :output
  end
  
end
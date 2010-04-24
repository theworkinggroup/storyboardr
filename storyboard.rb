require 'sinatra/base'
require 'fastercsv'
require 'lib/extensions'

$: << File.expand_path('lib/prawn/lib', File.dirname(__FILE__))
require 'prawn'


class Storyboard < Sinatra::Base
  
  get '/' do
    erb :index
  end
  
  post '/' do
    filename = params[:file][:filename]
    file = params[:file][:tempfile]
    
    data = FasterCSV.parse(file)
    stories = data.collect do |project, type, story, estimate|
       {
        :project  => project,
        :type     => type,
        :story    => story,
        :estimate => estimate
      }
    end
    
    
    @pdf = Prawn::Document.new( :margin => 12 )
    
    table = []
    stories.in_groups_of(2, false) do |stories_line|
      row = []
      stories_line.each do |story|
        row << [
          [ Prawn::Table::Cell.make(@pdf, rendered_story(story), :width => 295) ],
          [ Prawn::Table::Cell.make(@pdf, 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', :width => 295, :border_color => 'cccccc', :font_size => 9, :text_color => 'ff0000', :background_color => '00ff00') ],
          [ Prawn::Table::Cell.make(@pdf, rendered_footer, :width => 295, :border_color => 'cccccc', :height => 50)]
        ]
      end
      table << row 
    end
    
    @pdf.table( table, :cell_style => { :border_color => 'cccccc' } )
    
    content_type 'application/pdf'
    attachment 'test.pdf'
    @pdf.render
  end
  
protected

  def rendered_story(story)
    [['project', 'type', 'estimate']]
  end
  
  def rendered_footer
    [['1','2','3','4']]
  end
    
  
end
require 'redmine'
require 'open-uri'
require 'issue'

Redmine::Plugin.register :redmine_wiki_sql do
  name 'Redmine Wiki SQL'
  author 'Rodrigo Ramalho'
  author_url 'http://www.rodrigoramalho.com/'
  description 'Allows you to run SQL queries and have them shown on your wiki in table format'
  version '0.0.1'

  Redmine::WikiFormatting::Macros.register do
    desc "Run SQL query"
    macro :sql do |obj, args, text|

        _sentence = args.join(",")
        _sentence = _sentence.gsub("\\(", "(")
        _sentence = _sentence.gsub("\\)", ")")
        _sentence = _sentence.gsub("\\*", "*")

        result = ActiveRecord::Base.connection.execute(_sentence)
        unless result.nil?
          unless result.num_rows() == 0
            column_names = []
            for columns in result.fetch_fields.each do
              column_names += columns.name.to_a
            end

            _thead = '<tr>'
            column_names.each do |column_name|
              _thead << '<th>' + column_name.to_s + '</th>'
            end
            _thead << '</tr>'

            _tbody = ''
            result.each_hash do |record|
              unless record.nil?
                _tbody << '<tr>'
                column_names.each do |column_name|
                  _tbody << '<td>' + record[column_name].to_s + '</td>'
                end
                _tbody << '</tr>'
              end 
            end

            text = '<table>' << _thead << _tbody << '</table>' 

            text.html_safe
          else
            ''.html_safe
          end
        else
          ''.html_safe
        end
    end 
  end
	
end

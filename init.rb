require 'redmine'
require 'open-uri'
require 'issue'

Redmine::Plugin.register :redmine_wiki_sql do
  name 'Redmine Wiki SQL'
  author 'Rodrigo Ramalho'
  author_url 'http://www.rodrigoramalho.com/'
  description 'Allows you to run SQL queries and have them shown on your wiki in table format'
  version '0.2'

  Redmine::WikiFormatting::Macros.register do
    desc "Run SQL query"
    macro :sql do |obj, args, text|

        _sentence = args.join(",")
        _sentence = _sentence.gsub("\\(", "(")
        _sentence = _sentence.gsub("\\)", ")")
        _sentence = _sentence.gsub("\\*", "*")

        result = ActiveRecord::Base.connection.exec_query(_sentence)
        _thead = '<thead><tr>'
        result.columns.each do |column|
          _thead << '<th>' + column.to_s + '</th>'
        end
        _thead << '</tr></thead>'

        unless result.empty?()
          _tbody = '<tbody>'
          result.each do |row|
            _tbody << '<tr>'
            result.columns.each do |column|
              _tbody << '<td>' + row[column.to_s].to_s + '</td>'
            end
            _tbody << '</tr>'
          end
          _tbody << '</tbody>'
        else
          _tbody = ''
        end
        text = '<table>' << _thead << _tbody << '</table>' 
        text.html_safe
    end 
  end
	
end

require 'redmine'
require 'mysql2'
require 'open-uri'
require 'issue'

Redmine::Plugin.register :redmine_wiki_sql do
  name 'Secure Wiki SQL'
  author 'Rodrigo Ramalho, Domingo Galdos'
  author_url 'http://www.rodrigoramalho.com/'
  description 'Securely insert SQL-query-backed tables in the wiki from a relational database'
  version '0.3.0'
  settings :default => {'empty' => true}, :partial => 'settings/redmine_wiki_sql'


  Redmine::WikiFormatting::Macros.register do
    desc "Run SQL query"
    macro :sql do |obj, args, text|
        # TODO: textilizable 
        # TODO: Groups
        sql_field_values = User.current.custom_field_values.select{ |cv| cv.custom_field.name == "SQL Authority" }
        has_authority = !sql_field_values.empty? && '1' == sql_field_values.first.value
        out_text = ""
        if has_authority
            _sentence = text

            # TODO: support other RDBMS vendors besides MySQL, eg Postgres, MSSQL, SQLite, Oracle
            dbh = Mysql2::Client.new(
                :host => Setting.plugin_redmine_wiki_sql['rdbms_host'],
                :username => Setting.plugin_redmine_wiki_sql['rdbms_username'],
                :password => Setting.plugin_redmine_wiki_sql['rdbms_password'],
                :port => Setting.plugin_redmine_wiki_sql['rdbms_port'],
                :database => args[0],
                :read_timeout => 30,
                :write_timeout => 30,
                :connect_timeout => 30
            )
            result = dbh.query(_sentence)

            unless result.nil?
              #unless result.num_rows() == 0
              unless result.fields.length == 0
                column_names = result.fields

                _thead = '<tr>'
                column_names.each do |column_name|
                  _thead << '<th>' + column_name.to_s + '</th>'
                end
                _thead << '</tr>'

                _tbody = ''
                result.each do |record|
                  unless record.nil?
                    _tbody << '<tr>'
                    jj = 0
                    column_names.each do |column_name|
                      raw_cell = record[column_names[jj]].to_s
                      formatted_cell =  textilizable( raw_cell )
                      _tbody << '<td>' + formatted_cell + '</td>'
                      jj = jj + 1
                    end
                    _tbody << '</tr>'
                  end 
                end
                out_text = '<table>' << _thead << _tbody << '</table>' 
              end
            end
        end
        out_text.html_safe
    end 
  end
	
end



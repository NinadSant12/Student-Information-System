
require 'dm-core'
require 'dm-migrations'
require './main'
require './comment'

DataMapper.setup(:default, ENV['DATABASE_URL']|| "sqlite3://#{Dir.pwd}/development.db")
configure do
  enable :sessions
  set :username, "NinadSant"
  set :password, "westeros"
end


class Student
  include DataMapper::Resource
  property :id, Serial
  property :firstname, String
  property :lastname, String
  property :birthday, Date
  property :address, String
  property :studentid, String

  def birthday=date
    super Date.strptime(date, '%m/%d/%Y')
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/students' do
  @students = Student.all
  if session[:admin] == true
    erb :students, :layout => :layout2
  else
    erb :students, :layout => :layout1
  end
end

get '/students/new' do
  redirect to('/logout') unless session[:admin]
  student = Student.new
  erb :new_student
end

get '/login' do
  erb :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
      session[:admin] = true
      erb :logged, :layout => :layout2
  else
    erb :login
  end
end

get '/logout' do
session.clear
session[:admin] = false
erb :login, :layout => :layout1

end


get '/students/new' do
  redirect to('/logout') unless session[:admin]
  @student = Student.new
  erb :new_student
end


get '/students/:id' do
  @student = Student.get(params[:id])
  erb :show_student
end


get '/students/:id/edit' do
  redirect to('/logout') unless session[:admin]
  @student = Student.get(params[:id])
  erb :edit_student
end

#...................Add a student's data..........................
post '/students' do
  redirect to('/logout') unless session[:admin]
  @student = Student.create(params[:student])
  redirect to('/students')
end

#..................Modify a student's data........................
put '/students/:id' do
  redirect to('/logout') unless session[:admin]
  @student = Student.get(params[:id])
  @student.update(params[:student])
  redirect to("/students/#{@student.id}")
end

#..................Delete student's data...........................
delete '/students/:id' do
  redirect to('/logout') unless session[:admin]
  Student.get(params[:id]).destroy
  redirect to('/students')
end

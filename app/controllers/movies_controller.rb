class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
		@all_ratings = Movie.all_ratings
		redirect = false

		if params[:sort] == nil
			current_sort = session[:sort]
			if session[:sort] != nil
				redirect = true
			end
		else
			current_sort = params[:sort]
			session[:sort] = params[:sort] 
		end
		
		if params[:ratings] == nil and session[:ratings] == nil
			@filtered_ratings = {"G" => "1", "PG" => "1", "PG-13" => "1", "R" => "1", "NC-17" => "1"}
		elsif params[:ratings] == nil
			@filtered_ratings = session[:ratings]
			redirect = true
		else
			@filtered_ratings = params[:ratings]
			session[:ratings] = params[:ratings]
		end
		
		if redirect
			flash.keep
			redirect_to movies_path(:ratings => @filtered_ratings, :sort => current_sort)
			redirect = false
			return
		end

		if current_sort == 'title'
			@movies = Movie.order("lower(title) ASC").find(:all, :conditions => ["rating IN (?)", @filtered_ratings.keys])
		elsif current_sort == 'date'
			@movies = Movie.find(:all, :conditions => ["rating IN (?)", @filtered_ratings.keys]).sort_by &:release_date
		else
			@movies = Movie.find(:all, :conditions => ["rating IN (?)", @filtered_ratings.keys])
		end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end

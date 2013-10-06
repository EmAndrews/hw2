class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
		@all_ratings = Movie.all_ratings
    @filtered_ratings = Movie.all_ratings
    if session[:filtered_ratings] == nil
      session[:filtered_ratings] = @filtered_ratings
    else
      # This populates @filtered_ratings with checked box values
      if params[:ratings] != nil
        @filtered_ratings = []
        params[:ratings].each do |k,v|
          if v == "1"
            @filtered_ratings << k
          end
        end
      # if there are no checked box vals, we do:
      else
        @filtered_ratings = session[:filtered_ratings]
        params[:ratings] = Hash.new()
        session[:filtered_ratings].each do |k|
          params[:ratings][k] = "1"
        end
      end
      session[:filtered_ratings] = @filtered_ratings
    end

    sort = params[:sort]
    if sort == 'title'
      @movies = Movie.order("lower(title) ASC").all
    elsif sort == 'date'
      @movies = Movie.all.sort_by &:release_date
    else
      @movies = Movie.find(:all, :conditions => ["rating IN (?)", @filtered_ratings])
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

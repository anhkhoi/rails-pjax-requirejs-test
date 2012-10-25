class ItemsController < ApplicationController
  include ActionController::Live
  
  # GET /items
  # GET /items.json
  def index
    @items = load_items(params)

    respond_to do |format|
      format.html { render stream: true }
      format.json { render json: @items }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = load_item(params)

    respond_to do |format|
      format.html do
        @guides = @item.guides
        render stream: true
      end
      format.json { render json: @item }
    end if stale? @item
  end
  
  # GET /items/1/live
  def live
    response.headers["Content-Type"] = "text/event-stream"
    
    sse = SSEStream.new(response.stream)
    
    begin
      loop do
        sse.write(time: Time.now)
        sleep 1
      end
    rescue IOError
      # no-op (disconnect)
    ensure
      sse.close
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = load_item(params)
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render json: @item, status: :created, location: @item }
        format.js { render :form }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
        format.js { render :form }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = load_item(params)

    respond_to do |format|
      if @item.update_attributes(item_params)
        format.html { redirect_to @item, notice: "Item was successfully updated." }
        format.json { render json: @item }
        format.js { render :form }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
        format.js { render :form }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = load_item(params)
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
      format.json { head :no_content }
      format.js
    end
  end
  
  protected
  def item_params
    params.require(:item).permit(:title, :description)
  end

  def load_items(options = {})
    Item.all
  end
  
  def load_item(options = {})
    Item.find(params[:id])
  end
end

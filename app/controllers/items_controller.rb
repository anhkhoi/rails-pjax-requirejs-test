class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
    @items = Item.all
    
    # HTTP cache
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end if stale? @items.sort_by(&:updated_at).last
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])
    
    # HTTP cache
    respond_to do |format|
      format.html { @guides = @item.guides }
      format.json { render json: @item }
    end if stale? @item
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
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(params[:item])

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
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
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
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
      format.json { head :no_content }
      format.js
    end
  end
end

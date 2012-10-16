class GuidesController < ApplicationController
  before_filter :load_item
  before_filter :load_guide, except: [ :index, :new, :create ]
  
  def index
    @guides = @item.guides

    respond_with(@guides) do |format|
      format.html { redirect_to @item }
    end if stale? @guides.sort_by(&:updated_at).last
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @guide }
    end if stale? @guide
  end

  # GET /guides/new
  # GET /guides/new.json
  def new
    @guide = @item.guides.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @guide }
    end
  end

  # GET /guides/1/edit
  def edit; end

  # POST /guides
  # POST /guides.json
  def create
    @guide = @item.guides.build(params[:guide])

    respond_to do |format|
      if @guide.save
        @item.touch
        format.any(:html, :mobile) { redirect_to [@item, @guide], notice: "Guide was successfully created." }
        format.json { render json: @guide, status: :created, location: [@item, @guide] }
        format.js { render :form }
      else
        format.any(:html, :mobile) { render action: "new" }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
        format.js { render :form }
      end
    end
  end

  # PUT /guides/1
  # PUT /guides/1.json
  def update
    respond_to do |format|
      if @guide.update_attributes(params[:guide])
        @item.touch
        format.any(:html, :mobile) { redirect_to [@item, @guide], notice: "Guide was successfully updated." }
        format.json { render json: @guide }
        format.js { render :form }
      else
        format.html { render action: "edit" }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
        format.js { render :form }
      end
    end
  end

  # DELETE /guides/1
  # DELETE /guides/1.json
  def destroy
    @guide.destroy
    @item.touch

    respond_to do |format|
      format.html { redirect_to @item, notice: "Guide was successfully deleted." }
      format.mobile { redirect_to item_guides_path(@item), notice: "Guide was successfully deleted." }
      format.json { head :no_content }
      format.js
    end
  end
  
  protected
  def load_item
    @item = find_item(params)
  end
  
  def load_guide
    @guide = find_guide(@item, params)
  end
  
  def find_item(params)
    Item.find(params[:item_id])
  end
  
  def find_guide(item, params)
    item.guides.find(params[:id])
  end
end
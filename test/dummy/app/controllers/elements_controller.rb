
class ElementsController < ApplicationController
  before_action :set_owner

  def index
    @elements = InOrder::Fetch.new(@owner).elements

    @subjects = Subject.all
  end

  def create
    subject = Subject.find params[:subject_id]

    InOrder::Add.new(@owner).call(subject)

    redirect_to [ @owner, :elements ], notice: 'Added!'
  end

  def destroy
    target = params[:id]

    InOrder::Remove.new(target).call

    redirect_to [ @owner, :elements ], notice: 'Deleted!'
  end

  private

  def set_owner
    @owner = Owner.find params[:owner_id]
  end
end


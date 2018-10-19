module Dradis::CE::API
  module V1
    class CommentsController < Dradis::CE::API::V1::ProjectScopedController
      before_action :set_comment, only: [:show, :update, :destroy]
      before_action :set_commentable, only: [:index, :create]

      def index
        @comments = @commentable.comments
      end

      def show; end

      def create
        @comment = @commentable.comments.build(comment_params)
        @comment.user = current_user
        if @comment.save
          track_created(@comment)
          render status: 201, location: @commentable
        else
          render_validation_errors(@comment)
        end
      end

      def update
        if @comment.update_attributes(comment_params)
          track_updated(@comment)
        else
          render_validation_errors(@comment)
        end
      end

      def destroy
        @comment.destroy
        track_destroyed(@comment)
        render_successful_destroy_message
      end

      private

      def comment_params
        params.require(:comment).permit(:content)
      end

      def set_commentable
        @commentable =
          if params[:issue_id]
            Issue.find(params[:issue_id])
          elsif params[:note_id]
            Note.find(params[:note_id])
          elsif params[:evidence_id]
            Evidence.find(params[:evidence_id])
          else
            raise 'Polymorphic model missing!'
          end
      end

      def set_comment
        @comment = Comment.find(params[:id])
      end
    end
  end
end

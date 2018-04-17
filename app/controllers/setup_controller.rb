class SetupController < ProjectScopedController

  def complete
    SetupWizard.complete
    flash[:show_completed] = params[:show_completed]
    redirect_to summary_path
  end

  def current_step
    step = SetupWizard.next_step
    redirect_to "setup_#{step}".to_sym
  end

  def next_step
    step = SetupWizard.next_step
    SetupWizard.advance_step

    redirect_to "setup_#{step}".to_sym
  end

  def testing_methodology
  end

  def scope
  end

  def upload
  end
end

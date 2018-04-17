class SetupWizard
  STEPS = [
    :testing_methodology,
    :scope,
    :upload,
    :complete
  ]

  def self.advance_step
    step       = Configuration.setup_next_step
    step.value = STEPS[STEPS.index(step.value.to_sym) + 1] || STEPS.last
    step.save
  end

  def self.complete
    show_setup       = Configuration.setup_show
    show_setup.value = 'false'
    show_setup.save
  end

  def self.next_step
    Configuration.setup_next_step.value.to_sym
  end

  def self.show?
    Configuration.setup_show.value == 'true'
  end
end

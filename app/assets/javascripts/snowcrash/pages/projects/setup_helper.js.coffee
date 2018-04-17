document.addEventListener 'turbolinks:load', ->
  if $("[data-behaviour~='setup-helper']").length
    $("[data-behaviour~='dismiss_setup_helper']").on 'click', ->
      $('.setup-helper').hide()

#= require jquery
#= require jquery_ujs
#= require underscore/underscore-min
#= require bootstrap.min
#= require jquery.carouFredSel-6.2.1-packed
#= require jquery-ui-1.10.3/js/jquery-ui-1.10.3.custom.min
#= require jquery-ui-1.10.3/touch-fix.min
#= require isotope/jquery.isotope.min
#= require bootstrap-tour/build/js/bootstrap-tour.min
#= require prettyphoto/js/jquery.prettyPhoto
#= require goMap/js/jquery.gomap-1.3.2.min
#= require custom
#= require modernizr.custom.56918
#= require redactor-rails
#= require spin
#= require jquery.spin
#= require typeahead
#= require hogan-2.0.0

# Attach a function or variable to the global namespace
root = exports ? this

#####################################
#    Check if console exists (IE)   #
#####################################
log = (message) ->
  if typeof console is 'object' then console.log(message) else return null

$(document).ready ->
    update_sku()
    select_shipping()
    loading_animation_settings()
    modal('.notify_me', '#notifyMeModal')
    typeahead_engine()

    $('#order_shipping_country').change ->
        unless @value is ""
        	$.ajax '/update_country',
        		type: 'GET'
        		data: {'country_id' : @value, 'tier_id' : $('.shipping-methods').attr 'data-tier' }
        		dataType: 'html'
        		success: (data) ->
        			$('.shipping-methods .control-group .controls').html data
        else 
            $('.shipping-methods .control-group .controls').html '<p class="shipping_notice">Select a shipping country to view the available shipping options.</p>'

    $('#update_quantity').click ->
        $('.edit_cart_item').each ->
            $(@).submit()

    loading_modal('.paypal_checkout', '#paypalModal')
    loading_modal('.confirm_order', '#confirmOrderModal')

$(document).ajaxComplete ->
    update_sku()
    select_shipping()
    modal('.notify_me', '#notifyMeModal')
    form_JSON_errors()

form_JSON_errors = ->
    $(document).on "ajax:error", "form", (evt, xhr, status, error) ->
        errors = $.parseJSON(xhr.responseJSON.errors)
        $.each errors, (key, value) ->
            $element = $("input[name*='" + key + "']")
            $error_target = '.error_explanation'
            if $element.parent().next().is $error_target
                $($error_target).html '<span>' + key + '</span> ' + value
            else 
                $element.wrap '<div class="field_with_errors"></div>'
                $element.parent().after '<span class="' + $error_target.split('.').join('') + '"><span>' + key + '</span> ' + value + '</span>'

modal = (trigger, target) ->
    $(trigger).click ->
        $(target).modal 'show'
        return false

loading_modal = (trigger, target) ->
    $(trigger).click ->
        $(target).modal 'show'
        $(target + ' .modal-body .loading_block').spin 'standard'

select_shipping = ->
    $('.shipping-methods .option').click ->
        $(@).find('input:radio').prop 'checked', true
        $('.option').removeClass 'active'
        $(@).addClass 'active'
    $('.shipping-methods .option input:radio').each ->
        $(@).parent().addClass 'active' if $(@).is ':checked'

update_sku = ->
    $('#cart_item_sku_id').change ->
        sku_id = $(@).val()
        $.get '/update_sku?sku_id=' + sku_id

loading_animation_settings = ->
    $.fn.spin.presets.standard =
        lines: 9 # The number of lines to draw
        length: 0 # The length of each line
        width: 10 # The line thickness
        radius: 18 # The radius of the inner circle
        corners: 1 # Corner roundness (0..1)
        rotate: 0 # The rotation offset
        direction: 1 # 1: clockwise, -1: counterclockwise
        color: "#e54b5d" # #rgb or #rrggbb
        speed: 0.8 # Rounds per second
        trail: 42 # Afterglow percentage
        shadow: false # Whether to render a shadow
        hwaccel: false # Whether to use hardware acceleration
        className: "spinner" # The CSS class to assign to the spinner
        zIndex: 2e9 # The z-index (defaults to 2000000000)
        top: "auto" # Top position relative to parent in px
        left: "auto" # Left position relative to parent in px

typeahead_engine = ->
    $("#navSearchInput").typeahead(
        remote: "/search.json?utf8=✓&query=%QUERY"
        # prefetch: "/search.json"
        template: "<div class='inner-suggest'><img src='{{image.file.url}}'/><span><div>{{value}}</div>{{category_name}}{{}}</span></div>"
        engine: Hogan
        limit: 4
    ).on "typeahead:selected", ($e, data) ->
        window.location = "/releases/" + data.category_slug + "/products/" + data.product_slug

    # dataquery = $('.search-data-query')
    # searchquery = $('#navSearchInput')

    # typepos = $('#navSearchInput').offset()
    # $('.search-data-query').css "left", typepos["left"]


    # searchquery.bind "input", ->
    #   if searchquery.val() is ""
    #     dataquery.hide()
    #   else
    #     s_query = searchquery.val()
    #     dataquery.show().html("<a href ='/search?utf8=✓&query=" + s_query + "'><div>Search for '<span>" + s_query + "</span>'</div></a>").addClass "data-query-highlight"

    # searchquery.blur ->
    #   setTimeout (->
    #     dataquery.hide()
    #   ), 150

    # searchquery.focus ->
    #   unless searchquery.val() is ""
    #     dataquery.show().addClass "data-query-highlight"

    # dataquery.hover ->
    #   $('.tt-suggestion').removeClass 'tt-is-under-cursor'

    # $('.tt-dropdown-menu').hover ->
    #   dataquery.removeClass "data-query-highlight"

    # searchquery.keydown (event) ->
    #   dataquery.removeClass "data-query-highlight"  if event.keyCode is 40
    #   dataquery.removeClass "data-query-highlight"  if event.keyCode is 38

    #   unless $('.tt-suggestion').hasClass "tt-is-under-cursor"
    #     dataquery.addClass "data-query-highlight"  if event.keyCode is 38
    #     dataquery.addClass "data-query-highlight"  if event.keyCode is 40

    #   if dataquery.hasClass "data-query-highlight"
    #     $('#').submit()  if event.keyCode is 13

    # $(document)[0].oncontextmenu = ->
    # false

    # $(document).mousedown (e) ->
    #   if e.button is 2
    #     dataquery.hide()
    #     $('.tt-dropdown-menu').hide()
    #     false
    #   else
    #     true




jQuery(function() {
    // Bind the click handler of some button on your page
    jQuery('#spinValid').click(function(evt) {
        jQuery('#spin_answer').html(getSelectedText());
        evt.preventDefault();
    });
});

// Get user selection text on page
function getSelectedText() {
    if (window.getSelection) {
        return window.getSelection();
    }
    else if (document.selection) {
        return document.selection.createRange().text;
    }
    return '';
}
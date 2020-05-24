//= require activestorage
//= require turbolinks
//= require_tree .
//= require jquery
//= require jquery_ujs

$(function() {
    $('.confirm').click(function () {
        return confirm($(this).attr('data-target-name') + 'を行います。\nよろしいでしょうか?');
    });
    $('.edit_participant').submit(function() {
        if ($('#participant_entry_status').val() == 2) {
            return confirm('エントリーステータスを「拒否」にすると、状態を元に戻すことはできません。\n実行しますか?');
        }
    });
});
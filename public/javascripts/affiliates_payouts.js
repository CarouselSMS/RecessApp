$(document).ready(function(){
    $('select#type').change(function(){
        if($(this).val() == 'range' ){
            $('input#start_date').add('input#end_date').show()
        }else{
            $('input#start_date').add('input#end_date').hide()
        }
    });

    $('select#type').trigger('change');

    $('input#start_date').add('input#end_date').datepicker({ dateFormat: 'yy-mm-dd' });
})
// 
// 
var video_html = '<iframe src="//www.youtube.com/embed/ViphzuTd4Ws?autoplay=1&rel=0" frameborder="0"></iframe>';
$(document).ready(function() {
  var $video = $('#video');

  var videoWidth = $video.width();
  var videoHeight = videoWidth / 16.0 * 9.0;

  $video.find('a.play div').width(videoWidth).height(videoHeight);

  var $play = $video.find('a.play img');
  $play.css({
    top: (videoHeight-90)/2,
    left: (videoWidth-90)/2
  });

  /**
  *
  */
  $video.find('a.play').click(function() {
    $(this).fadeOut();
    $(video_html).width(videoWidth).height(videoHeight).appendTo('#video');
    return false;
  });
});

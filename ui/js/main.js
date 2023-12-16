window.addEventListener('message', (event) => {
    if (event.data.type === 'open') {
        $(".cammenu").fadeIn();
        $(".kapimenu").fadeIn();
        $(".koltukmenu").fadeIn();
        $(".ana").fadeIn();
    } else if (event.data.type === 'close') {
        close();
    } else if (event.data.type === 'update') {
        let data = event.data.data
        for (x in data) {
            changeStatus(x, data[x])
        }
    }
});

function changeStatus(dclass, status) {
    if (status == "pasif") {
        $("#"+dclass+" .button-cizgi").addClass("pasif");
        $("#"+dclass+" .button-cizgi").removeClass("aktif");
    } else if (status) {
        $("#"+dclass+" .button-cizgi").addClass("aktif");
        $("#"+dclass+" .button-cizgi").removeClass("pasif");
    } else {
        $("#"+dclass+" .button-cizgi").removeClass("aktif");
        $("#"+dclass+" .button-cizgi").removeClass("pasif");
    }
}

function close() {
    $(".cammenu").fadeOut();
    $(".kapimenu").fadeOut();
    $(".koltukmenu").fadeOut();
    $(".ana").fadeOut();
    $.post('http://bCarControl/kapat')
}

$(document).on("click", ".button", function() {
    $.post('http://bCarControl/set', JSON.stringify({tip: this.id}));
});

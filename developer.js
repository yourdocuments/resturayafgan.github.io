// নিচের "Connect with Developer" বাটনের তথ্য এখানে বদলান
// link এ নিজের WhatsApp / Facebook / ফোন / ইমেইল লিংক দিন। উদাহরণ:
//   WhatsApp:  https://wa.me/8801XXXXXXXXX     (XXXXXXXXX এর জায়গায় নিজের নম্বর, 880 দিয়ে শুরু)
//   Facebook:  https://facebook.com/আপনার-পেজ
//   ইমেইল:     mailto:you@example.com
// link এ "XXXX" লেখা থাকলে বাটনটা দেখাবে না।
const DEV = {
  text: "Want a website like this for your business?",
  button: "Connect with Developer",
  link: "https://snkbp.com"
};

(function () {
  const bar = document.getElementById('devbar');
  if (!bar || !DEV.link || /XXXX/i.test(DEV.link)) return;
  const esc = s => String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  bar.innerHTML = `<span>${esc(DEV.text)}</span> <a href="${esc(DEV.link)}" target="_blank" rel="noopener">${esc(DEV.button)}</a>`;
  bar.hidden = false;
})();

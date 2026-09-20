<?php
$data = json_decode(file_get_contents(__DIR__ . '/data.json'), true);
$s = $data['settings'];
function e($v){ return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
$hero = $s['hero_image'] ? "style=\"background-image:url('uploads/" . e($s['hero_image']) . "')\"" : '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= e($s['name']) ?></title>
<meta name="description" content="<?= e($s['tagline']) ?>">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,600;0,700;1,500&family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="style.css">
</head>
<body>

<header>
  <div class="wrap">
    <a href="#home" class="logo"><?= e(strtoupper(str_replace(' Restaurant','',$s['name']))) ?><small>RESTAURANT</small></a>
    <nav id="nav">
      <a href="#home">Home</a><a href="#menu">Menu</a><a href="#about">About Us</a><a href="#gallery">Gallery</a><a href="#contact">Contact</a>
    </nav>
    <a class="btn" href="https://wa.me/<?= e($s['whatsapp']) ?>" target="_blank" rel="noopener">Order Now</a>
    <button class="menu-btn" aria-label="Menu" onclick="document.getElementById('nav').classList.toggle('open')">☰</button>
  </div>
</header>

<section class="hero" id="home" <?= $hero ?>>
  <div class="wrap">
    <div class="hi">Welcome to</div>
    <h1><?= e(strtoupper(str_replace(' Restaurant','',$s['name']))) ?></h1>
    <div class="sub">RESTAURANT</div>
    <p><?= e($s['tagline']) ?></p>
    <div class="btns">
      <a class="btn" href="#menu">View Menu</a>
      <a class="btn outline" href="https://wa.me/<?= e($s['whatsapp']) ?>" target="_blank" rel="noopener">Order Now</a>
    </div>
  </div>
</section>

<section class="about" id="about">
  <div class="wrap">
    <div>
      <h2><?= e($s['about_title']) ?></h2>
      <p><?= e($s['about_text']) ?></p>
      <a class="btn" href="#contact">Learn More</a>
    </div>
    <div class="feats">
      <div><div class="ic">👨‍🍳</div><h3>Fresh Ingredients</h3><p>We use the freshest ingredients to serve you the best.</p></div>
      <div><div class="ic">🍽️</div><h3>Hygienic Food</h3><p>Hygiene and quality are our top priorities.</p></div>
      <div><div class="ic">🤝</div><h3>Friendly Service</h3><p>Our friendly team is always here to serve you better.</p></div>
    </div>
  </div>
</section>

<section class="sec" id="menu">
  <div class="wrap">
    <h2>Our Popular Dishes</h2><div class="line"></div>
    <div class="cards">
      <?php foreach ($data['dishes'] as $d): ?>
        <article class="card">
          <?php if ($d['image']): ?>
            <img class="ph" src="uploads/<?= e($d['image']) ?>" alt="<?= e($d['name']) ?>" loading="lazy">
          <?php else: ?><div style="padding:0"><div class="ph"></div></div><?php endif; ?>
          <div><h3><?= e($d['name']) ?></h3><div class="price">৳ <?= e($d['price']) ?></div></div>
        </article>
      <?php endforeach; ?>
    </div>
  </div>
</section>

<section class="why">
  <div class="wrap">
    <h2>Why Choose Us</h2><div class="line"></div>
    <div class="grid">
      <div class="item"><div class="ic">🏅</div><h3>Best Quality</h3><p>We maintain the highest quality in our food.</p></div>
      <div class="item"><div class="ic">🏷️</div><h3>Affordable Price</h3><p>Delicious food at a price that fits your budget.</p></div>
      <div class="item"><div class="ic">♥</div><h3>Made with Love</h3><p>Every dish is made with care and love.</p></div>
      <div class="item"><div class="ic">⏱️</div><h3>Fast Service</h3><p>We value your time and serve you quickly.</p></div>
    </div>
  </div>
</section>

<section class="sec" id="gallery">
  <div class="wrap">
    <h2>Our Gallery</h2><div class="line"></div>
    <div class="gal">
      <?php if ($data['gallery']): foreach ($data['gallery'] as $g): ?>
        <img src="uploads/<?= e($g['image']) ?>" alt="Gallery photo" loading="lazy">
      <?php endforeach; else: for ($i=0;$i<6;$i++): ?><div class="ph"></div><?php endfor; endif; ?>
    </div>
  </div>
</section>

<footer id="contact">
  <div class="wrap grid">
    <div>
      <div class="logo"><?= e(strtoupper(str_replace(' Restaurant','',$s['name']))) ?><small>RESTAURANT</small></div>
      <p style="margin-top:12px">Good food, good mood!<br>Thank you for dining with us.</p>
    </div>
    <div><h4>Quick Links</h4><ul><li><a href="#home">Home</a></li><li><a href="#menu">Menu</a></li><li><a href="#about">About Us</a></li><li><a href="#gallery">Gallery</a></li><li><a href="#contact">Contact</a></li></ul></div>
    <div><h4>Contact Us</h4><ul>
      <li>📞 <a href="tel:<?= e(preg_replace('/\s+/','',$s['phone'])) ?>"><?= e($s['phone']) ?></a></li>
      <li>📍 <?= e($s['address']) ?></li>
      <li>🕙 <?= e($s['hours']) ?></li></ul></div>
    <div><h4>Follow Us</h4>
      <div class="soc">
        <?php if ($s['facebook']): ?><a href="<?= e($s['facebook']) ?>" target="_blank" rel="noopener" aria-label="Facebook">f</a><?php endif; ?>
        <?php if ($s['instagram']): ?><a href="<?= e($s['instagram']) ?>" target="_blank" rel="noopener" aria-label="Instagram">ig</a><?php endif; ?>
        <a href="https://wa.me/<?= e($s['whatsapp']) ?>" target="_blank" rel="noopener" aria-label="WhatsApp">wa</a>
      </div>
    </div>
  </div>
  <div class="copy">© <?= date('Y') ?> <?= e($s['name']) ?>. All Rights Reserved.</div>
</footer>
</body>
</html>

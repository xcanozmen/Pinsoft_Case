# Pinsoft_Case

# Projeyi Dev Branch'i üzerinden inceleyebilirsiniz

Proje Özeti

Projeyi MVC mimarisi kullanarak geliştirdim.

İlk olarak Splash Ekranında internet bağlantısını kontrol edebilmek için NetworkMonitor Classını oluşturdum. Eğer kullanıcın internet bağlantısı var ise Splash Screen animasyonunu başlatıp animasyon bitince bir sonraki ekrana gönderdim.

Anasayfa ekranında Searchbara film adı yazılıp arama butonuna basıldığı zaman response'u alına kadar loading animasyonu gösterdim.Requestin atılacağı urle erişmek için URLManager Classını oluşturdum bu Classta Singleton patern kullandım.

Gelen filmleri basılı tutarak favori ekleme/çıkarma özelliği ekledim. Favori olarak eklenen filmlerin ID lerini CoreData kullanarak kullanıcının cihazında sakladım. ViewController ayağa kalktığında bu bilgileri cihazın içinden çekerek arama yaptığı filmlerde daha önce favori olarak eklediği film var ise filmin gösterildi cell'e yıldız ekledim.

Filmin detaylarının gösterildiği ekrandada URLManagerdan eriştiğim url'den response gelene kadar loading gösterdim. Ve FirebaseAnalytics'e logEvent olarak filmin önemli bilgilerini gönderdim.

Ek olarak bir ekran daha tasarladım. Özellik olarak tasarladığım bu ekranda kullanıcının sadece favori olarak eklediği filmleri liste halinde kullanıcıya gösterdim, tıklanılan filmin fotoğrafını Firebase Storage'a kaydettim ve eklenen fotoğrafının urli ile birlikte filmin diğer datalarını RealtimeDatabase e kayıt ettim.

Firebase Notification olarak Appdelegate e gerekli fonksiyonları ekledim fakat Apple Developer Hesabımın süresi dolduğu için Firebase'e gerekli setifikaları yükleyemedim.

** Requestleri her Viewcotrollerda ayrı ayrı tekrar yazmıştım(şuan sizin gördüğünüz kod halen öyle) ödevin süresi dolduktan sonra değiştirmek istemedim, fakat requestleride viewcontroller'a yazdığım extension'a ekledim ViewControllerdan sadece request functionunu çağırıyorum ve gerekli parametreleri veriyorum gelen response'u da aldıktan sonra completionHandler kullanarak ViewConrollerdan erişiyorum. Değerlendirirken bu durumu da dikkate almanızı rica ederim.

Kullandığım Kütüphaneler
-> Firebase -  Analytics, Messaging, Database, Storage
-> Alamofire
-> SDWebImage
-> SwiftyJSON


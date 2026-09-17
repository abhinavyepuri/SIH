import Link from "next/link";

export default function Footer() {
  return (
    <footer className="bg-navy text-white mt-auto">
      <div className="max-w-7xl mx-auto px-6 py-12">
        <div className="flex flex-col md:flex-row justify-between items-start gap-8">
          <div>
            <h3 className="font-serif text-2xl tracking-wider">AROHA</h3>
            <p className="text-xs text-gray-400 mt-1 max-w-xs lowercase">
              where artists meet the market
            </p>
          </div>
          <div className="flex gap-12 text-sm">
            <div className="flex flex-col gap-2">
              <Link href="#" className="text-gray-400 hover:text-white transition-colors">Terms</Link>
              <Link href="#" className="text-gray-400 hover:text-white transition-colors">Privacy</Link>
            </div>
            <div className="flex flex-col gap-2">
              <Link href="#" className="text-gray-400 hover:text-white transition-colors">Shipping</Link>
              <Link href="#" className="text-gray-400 hover:text-white transition-colors">Contact</Link>
            </div>
            <div className="flex flex-col gap-2">
              <span className="text-xs uppercase tracking-widest text-gold font-bold">Portals</span>
              <Link 
                href="/login?role=admin" 
                className="px-3.5 py-1.5 bg-white/10 hover:bg-gold hover:text-navy border border-white/20 rounded-lg text-xs font-medium text-gray-200 transition-colors inline-flex items-center gap-1.5 shadow-sm"
              >
                <span>🔒 Admin Portal</span>
              </Link>
              <Link 
                href="/login?role=artisan" 
                className="text-gray-400 hover:text-gold transition-colors text-xs"
              >
                Artisan Creator Studio
              </Link>
            </div>
          </div>
        </div>
        <div className="border-t border-gray-700 mt-8 pt-6 text-xs text-gray-500 text-center">
          © 2024 Aroha. Where artists meet the market.
        </div>
      </div>
    </footer>
  );
}

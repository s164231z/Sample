public class ScanHQ {

	/*
	 * Hypercubeの節点間の距離算出
	 */

	private int bits;
	public ScanHQ(int bits){
		this.bits = bits;
	}
	public int getBits(){
		return bits;
	}
	public int scan(){

		/*
		int bits;
		bits = getBits() - ((getBits() >>> 1) & 0x55555555);
		bits = (bits & 0x33333333) + ((bits >>> 2) & 0x33333333);
		bits = (bits + (bits >>> 4)) & 0x0f0f0f0f;
		bits = bits + (bits >>> 8);
		bits = bits + (bits >>> 16);
		return bits & 0x3f;
		*/

		return Integer.bitCount(getBits());
	}
}
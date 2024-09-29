// simulates wind effect in a piece of paper

shader_type canvas_item;

void vertex() {
	VERTEX.x += sin(VERTEX.y + TIME)*2.;
}

void fragment() {

}